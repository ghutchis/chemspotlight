/**********************************************************************
GetMetadataForFile.mm - Spotlight importer for chemistry files using Open Babel

Copyright (C) 2005-2010 by Geoffrey R. Hutchison

This file is based on the Open Babel project.
For more information, see <http://openbabel.org/>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
***********************************************************************/

// Current: Version 2.0, released 2010-07-01
// More information on ChemSpotlight, including version history can be found at:
// http://geoffhutchison.net/projects/chem/

// TODO: 
//       more file types (need support in Open Babel)
//       support for compressed filetypes (e.g., 1ABC.pdb.gz) -- need Apple bugfix
//       fragments / fingerprints for similarity searching and improved substructure searching
//       molecular descriptor metadata (e.g., LogP, etc.)

#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
// Add this if you want NSLog -- to log all entries (helps with debugging crashes)
#import <Foundation/Foundation.h>

#include <string>
#include <openbabel/mol.h>
#include <openbabel/obconversion.h>

// Defines for ChemSpotlight
#include "Subscripts.h"
#include "Superscripts.h"

using namespace OpenBabel;
using namespace std;

// Calculate the molecular formula and masses in one loop
void CalculateFormulaAndMasses(OBMol &mol, double &mw, double &mass, stringstream &formula);

/* -----------------------------------------------------------------------------
    Get metadata attributes from file
   
   This function's job is to extract useful information your file format supports
   and return it as a dictionary
   ----------------------------------------------------------------------------- */

Boolean GetMetadataForFile(void* thisInterface, 
			   CFMutableDictionaryRef attributes, 
			   CFStringRef contentTypeUTI,
			   CFStringRef pathToFile)
{
    /* Pull any available metadata from the file at the specified path */
    /* Return the attribute keys and attribute values in the dict */
    /* Return TRUE if successful, FALSE if there was no data provided */	
	
	if (!attributes || !pathToFile)
		return(FALSE);
	
  NSLog(@" ChemSpotlight importing file %@", pathToFile);
	
	// convert the CFString to a c-style string, and run through a C++ ifstream for Open Babel
	char inFile[BUFF_SIZE];
	CFStringGetCString(pathToFile, inFile, BUFF_SIZE, kCFStringEncodingISOLatin1);
	OBConversion conv(&cin,&cout);	
	ifstream ifs;
	ifs.open(inFile);
	if (!ifs)
		return(FALSE); // can't open the file, so bail
	
	OBFormat *pInFormat = conv.FormatFromExt(inFile);
	if (pInFormat == NULL || 	!conv.SetInFormat(pInFormat)) { // can't find the format or attach to OBConversion
		ifs.close();
		return(FALSE); // bail
	}
	
	conv.SetInStream(&ifs); // attach to our OBConversion object	
	
	bool haveSMILES, haveInChI; // Can we load SMILES and InChI formats for metadata output?
	OBFormat *pSMILESFormat, *pInChIFormat;
	pSMILESFormat = conv.FindFormat("can"); // Canonical SMILES
	haveSMILES = (pSMILESFormat != NULL);
	pInChIFormat = conv.FindFormat("inchi"); // InChI (and thus canonical)
	haveInChI = (pInChIFormat != NULL);
	
	OBMol mol;
	int molCount = 0; // number of molecules in the file
	string output; // output from SMILES or InChI strings
	string::size_type notwhite; // used to trim the whitespace
	
	// set up a bunch of arrays for the metadata
	CFMutableArrayRef arrayFormula = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayDisplayFormula = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayMass = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayDisplayMass = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arraySMILES = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayInChI = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayChirality = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayNumAtoms = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayNumBonds = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayNumResidues = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arrayDimension = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	CFMutableArrayRef arraySequence = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	
	// string for general text content (e.g., OBPairData for MDL SDfile properties, etc.)
	CFMutableStringRef textContent = CFStringCreateMutable(NULL, 0);
	
	// loop through all molecular records in the file
	while (ifs.peek() != EOF && ifs.good()) {
		mol.Clear();
		if (!conv.Read(&mol)) {
			if (!molCount)
				return(FALSE); // if we fail before we read any molecules (e.g., not a chemistry file, bail now)
			else
				break; // we might find an error inside a file -- index what we found so far
		}
		
		if (mol.Empty()) {
			continue; // skip empty molecules
		}
		molCount++;
		
		//////////////
		// Extract general text, e.g. from the title, comment, any "pair data" properties, etc.
		if (textContent) {
			// title
			if (strlen(mol.GetTitle()) > 0) {
				CFStringAppendCString(textContent, " ", kCFStringEncodingISOLatin1);
				CFStringAppendCString(textContent, mol.GetTitle(), kCFStringEncodingISOLatin1);
			}
			// comments
			if (mol.HasData(OBGenericDataType::CommentData)) {
				OBCommentData *cd = (OBCommentData*)mol.GetData(OBGenericDataType::CommentData);
				CFStringAppendCString(textContent, " ", kCFStringEncodingISOLatin1);
				CFStringAppendCString(textContent, (cd->GetData()).c_str(), kCFStringEncodingISOLatin1);
			}
			if (mol.HasData(OBGenericDataType::PairData)) {
				string pairData;
				vector<OBGenericData*>::iterator k;
				vector<OBGenericData*> vdata = mol.GetData();
				for (k = vdata.begin();k != vdata.end();k++) { // iterate through all pair data types and index
					if ((*k)->GetDataType() == OBGenericDataType::PairData) {
						pairData += " ";
						pairData += (*k)->GetAttribute(); // add both the key
						pairData += " " ;
						pairData += ((OBPairData*)(*k))->GetValue(); // and the value
					}
				}
				CFStringAppendCString(textContent, pairData.c_str(), kCFStringEncodingISOLatin1);
			}
		} // end if(textContent)
		
		//////////////
		// Grab the formula, molecular weight, exact mass, etc.
		double mw = 0.0; // standard mol. weight
		double mass = 0.0; // exact mass
    int roundedMW = 0;
		stringstream formula;
		CalculateFormulaAndMasses(mol, mw, mass, formula); // do this all at once, only one loop through all atoms
		if (arrayMass) {
      // FIXME: Bug in 10.6.x finder crashes on doubles. Yuck.
      // For now, we cast to int
      roundedMW = (int)mw;
			CFNumberRef tempNumberRef = CFNumberCreate(NULL, kCFNumberIntType, &roundedMW);
			if (tempNumberRef) {
				CFArrayAppendValue(arrayMass, tempNumberRef);
				CFRelease(tempNumberRef);
			}
		}
    // Convert for a string for #@%# Finder
		if (arrayDisplayMass) {
      CFStringRef displayMassRef = CFStringCreateWithFormat(NULL, 0, CFSTR("%12.4f"), mw);
			if (displayMassRef) {
				CFArrayAppendValue(arrayDisplayMass, displayMassRef);
				CFRelease(displayMassRef);
			}
		}
		
		// If we already read the formula from the file (e.g., a CML file), use that instead
		OBPairData *dp = (OBPairData *) mol.GetData("Formula");
		if (dp)
			formula.str(dp->GetValue());
		
		if (arrayFormula) {
			CFStringRef form = CFStringCreateWithCString(NULL, (formula.str()).c_str(), kCFStringEncodingUTF8);
			if (form) {
				CFArrayAppendValue(arrayFormula, form);
        CFRelease(form);
			}
     
			// replace numerals with subscripts for display
			if (arrayDisplayFormula) {
				CFMutableStringRef displayFormula = CFStringCreateMutable(NULL, 0);
				if (displayFormula) {
          if (mol.GetTotalCharge() == 0) {
            CFStringAppendFormat(displayFormula, NULL, CFSTR("%s"), formula.str().c_str());
          } else {
            CFStringAppendFormat(displayFormula, NULL, CFSTR("[%s]"), formula.str().c_str());
          }
          
					// defined in Subscripts.h
					ReplaceSubscripts(displayFormula);
          // OK, now add +/- and charge if needed
          if (mol.GetTotalCharge() != 0) {
            CFStringAppendFormat(displayFormula, NULL, CFSTR("%+d"), mol.GetTotalCharge());
            ReplaceSuperscripts(displayFormula);
         }
					CFArrayAppendValue(arrayDisplayFormula, displayFormula);
					CFRelease(displayFormula);
				}
			} // end if(arrayDisplayFormula)
		} // end if(arrayFormula)
		
		//////////////
		// Get a SMILES string for this molecule
		// but only if we loaded the SMILES format, we have memory for the array, and a small molecule
		if (haveSMILES && arraySMILES && mol.NumAtoms() <= 200) {
			conv.SetOutFormat(pSMILESFormat);
			output = conv.WriteString(&mol);
			notwhite = output.find_first_of(" \t\n\r");
			if (notwhite != string::npos)
				output.erase(notwhite);
			CFStringRef smilesRef = CFStringCreateWithCString(NULL, output.c_str(), kCFStringEncodingISOLatin1);
			if (smilesRef) {
				CFArrayAppendValue(arraySMILES, smilesRef);
				CFRelease(smilesRef);
			}
		} // end SMILES
		
		// Add an InChI
		if (haveInChI && arrayInChI && mol.NumAtoms() <= 512) {
			conv.SetOutFormat(pInChIFormat);
			output = conv.WriteString(&mol);
			notwhite = output.find_first_of(" \t\n\r");
			if (notwhite != string::npos)
				output.erase(notwhite);
			CFStringRef inchiRef = CFStringCreateWithCString(NULL, output.c_str(), kCFStringEncodingISOLatin1);
			if (inchiRef) {
				CFArrayAppendValue(arrayInChI, inchiRef);
				CFRelease(inchiRef);
			}
		} // end InChI
		
		//////////////
		// Output residue sequences if available
		if (arraySequence && mol.NumResidues() != 0) {
			unsigned int currentChain = 0;
			string residueList;
			CFStringRef sequenceRef;
			FOR_RESIDUES_OF_MOL(r, mol) {
				if (r->GetName().find("HOH") != string::npos)
					continue;
				
				if (r->GetChainNum() != currentChain) {
					if (residueList.size() != 0) {
						residueList.erase(residueList.size() - 1);
						sequenceRef = CFStringCreateWithCString(NULL, residueList.c_str(), kCFStringEncodingISOLatin1);
						if (sequenceRef) {
							CFArrayAppendValue(arraySequence, sequenceRef);
//							CFRelease(sequenceRef);
						}
					}
					currentChain = r->GetChainNum();
					residueList.clear();
				}
				residueList += r->GetName();
				residueList += "-";
			}
			if (residueList.size() != 0) {
				residueList.erase(residueList.size() - 1);
				sequenceRef = CFStringCreateWithCString(NULL, residueList.c_str(), kCFStringEncodingISOLatin1);
				if (sequenceRef) {
					CFArrayAppendValue(arraySequence, sequenceRef);
					CFRelease(sequenceRef);
				}
			}
		} // end residue sequence
		
		//////////////
		// Check chirality
		if (mol.IsChiral() && arrayChirality)
			CFArrayAppendValue(arrayChirality, kCFBooleanTrue);
		else if (!mol.IsChiral() && arrayChirality)
			CFArrayAppendValue(arrayChirality, kCFBooleanFalse);
		
		//////////////
		// Number of atoms, bonds and residues
		unsigned int count;
		count = mol.NumAtoms();
		CFNumberRef tempNumberRef = CFNumberCreate(NULL, kCFNumberIntType, &count);
		if (arrayNumAtoms && tempNumberRef) {
			CFArrayAppendValue(arrayNumAtoms, tempNumberRef);
			CFRelease(tempNumberRef);
		}
		count = mol.NumBonds();
		tempNumberRef = CFNumberCreate(NULL, kCFNumberIntType, &count);
		if (arrayNumAtoms && tempNumberRef) {
			CFArrayAppendValue(arrayNumBonds, CFNumberCreate(NULL, kCFNumberIntType, &count));
			CFRelease(tempNumberRef);
		}
		count = mol.NumResidues();
		tempNumberRef = CFNumberCreate(NULL, kCFNumberIntType, &count);
		if (arrayNumAtoms && tempNumberRef) {
			CFArrayAppendValue(arrayNumResidues, CFNumberCreate(NULL, kCFNumberIntType, &count));
			CFRelease(tempNumberRef);
		}
		
		//////////////
		// Dimension
		if (arrayDimension) {
			switch (mol.GetDimension()) {
				case 3:
					CFArrayAppendValue(arrayDimension, CFSTR("3D"));
					break;
				case 2:
					CFArrayAppendValue(arrayDimension, CFSTR("2D"));
					break;
				default:
					CFArrayAppendValue(arrayDimension, CFSTR("0D"));
			} // end switch (dimension)
		} // end if (arryDimension exists)
	} // end while(readAMolecule)
	
	// set the "kind" of document based on the OBFormat we found
	// OBFormat::Description() is multiple lines and usually has "XYZ format" or somesuch
	string name = pInFormat->Description();
	name = name.substr(0, name.find('\n'));
	name = name.substr(0, name.find(" format"));
	name += " document";
	CFStringRef kindRef = CFStringCreateWithCString (NULL, name.c_str(), kCFStringEncodingISOLatin1);
	if (kindRef) {
		CFDictionarySetValue(attributes, CFSTR("kMDItemKind"), kindRef);
		CFDictionarySetValue(attributes, CFSTR("kMDItemDescription"), kindRef);
		CFRelease(kindRef);
	}
	
	// set the kMDItemTitle attribute to the title if there's only one molecule
	// (this is also stored in the kMDItemTextContent, so it's searchable for multi-molecule files too)
	if (molCount == 1) {
		CFStringRef titleRef = CFStringCreateWithCString(NULL, mol.GetTitle(), kCFStringEncodingISOLatin1);
		if (titleRef) {
			CFDictionarySetValue(attributes, CFSTR("kMDItemTitle"), titleRef);
			CFRelease(titleRef);
		}
		if (mol.HasData(OBGenericDataType::CommentData)) {
			OBCommentData *cd = (OBCommentData*)mol.GetData(OBGenericDataType::CommentData);
			CFStringRef commentRef = CFStringCreateWithCString(NULL, (cd->GetData()).c_str(), kCFStringEncodingISOLatin1);
			if (commentRef) {
				CFDictionarySetValue(attributes, CFSTR("kMDItemComment"), commentRef);
				CFRelease(commentRef);
			}
		} // commentData
	} // single molecule
		
	// Add our arrays to the metadata store
	if (textContent) {
		CFDictionarySetValue(attributes, CFSTR("kMDItemTextContent"), textContent);
		CFRelease(textContent);
	}
	CFNumberRef molCountRef = CFNumberCreate(NULL, kCFNumberIntType, &molCount);
	if (molCountRef) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_NumMols"), molCountRef);
		CFRelease(molCountRef);
	}
	if (arrayFormula) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_Formula"), arrayFormula);
		CFRelease(arrayFormula);
	}
	if (arrayDisplayFormula) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_DisplayFormula"), arrayDisplayFormula);
		CFRelease(arrayDisplayFormula);
	}
	if (arrayMass) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_Mass"), arrayMass);
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_ExactMass"), arrayMass);
		CFRelease(arrayMass);
	}
	if (arrayDisplayMass) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_DisplayMass"), arrayDisplayMass);
		CFRelease(arrayDisplayMass);
	}
	if (arraySMILES) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_SMILES"), arraySMILES);
		CFRelease(arraySMILES);
	}
	if (arrayInChI) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_InChI"), arrayInChI);
		CFRelease(arrayInChI);
	}
	if (arrayChirality) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_Chirality"), arrayChirality);
		CFRelease(arrayChirality);
	}
	if (arrayNumAtoms) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_NumAtoms"), arrayNumAtoms);
		CFRelease(arrayNumAtoms);
	}
	if (arrayNumBonds) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_NumBonds"), arrayNumBonds);
		CFRelease(arrayNumBonds);
	}
	if (arrayNumResidues) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_NumResidues"), arrayNumResidues);
		CFRelease(arrayNumResidues);
	}
	if (arrayDimension) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_Dimension"), arrayDimension);
		CFRelease(arrayDimension);
	}
	if (arraySequence) {
		CFDictionarySetValue(attributes, CFSTR("net_sourceforge_openbabel_Sequence"), arraySequence);
		CFRelease(arraySequence);
	}
	
	// return TRUE so that the attributes are imported
	return TRUE;
}

// As described -- in one pass, calculate the molecular weight, the exact isotopic mass, and the molecular formula
//  from the supplied OBMol &mol parameter
void CalculateFormulaAndMasses(OBMol &mol, double &mw, double &mass, stringstream &formula)
{
	const int NumElements = 110;
	// The elements in alphabetical order by symbol
	const int alphabetical[NumElements] = {
		89, 47, 13, 95, 18, 33, 85, 79, 5, 56, 4, 107, 83, 97, 35, 6, 20, 48,
		58, 98, 17, 96, 27, 24, 55, 29, 105, 66, 68, 99, 63, 9, 26, 100, 87, 31,
		64, 32, 1, 2, 72, 80, 67, 108, 53, 49, 77, 19, 36, 57, 3, 103, 71, 101,
		12, 25, 42, 109, 7, 11, 41, 60, 10, 28, 102, 93, 8, 76, 15, 91, 82, 46, 
		61, 84, 59, 78, 94, 88, 37, 75, 104, 45, 86, 44, 16, 51, 21, 34, 106, 14, 
		62, 50, 38, 73, 65, 43, 52, 90, 22, 81, 69, 92, 110, 23, 74, 54, 39, 70, 
		30, 40 };
	int atomicCount[NumElements];
	for (int i = 0; i < NumElements; i++)
		atomicCount[i] = 0;
	
	// Loop through and count all atoms & elements
	FOR_ATOMS_OF_MOL(a, mol)
	{
		int anum = a->GetAtomicNum();
		if (anum != 1) {
			// make sure to add any implicit hydrogens
			mw += etab.GetMass(1) * a->ImplicitHydrogenCount();
			mass += isotab.GetExactMass(1,1) * a->ImplicitHydrogenCount();
			atomicCount[0] += a->ImplicitHydrogenCount();
		}
		atomicCount[anum - 1]++;
		mw += a->GetAtomicMass();
		mass += a->GetExactMass();
	}
	
	// organize the formula in "Hill Order"
	// see http://en.wikipedia.org/wiki/Hill_system_order for more
	if (atomicCount[5] != 0) // Carbon (i.e. 6 - 1 = 5)
	{
		if (atomicCount[5] > 1)
			formula << "C" << atomicCount[5];
		else if (atomicCount[5] == 1)
			formula << "C";
		
		atomicCount[5] = 0; // So we don't output C twice
		
		// only output H if there's also carbon -- otherwise do it alphabetical
		if (atomicCount[0] != 0) // Hydrogen (i.e., 1 - 1 = 0)
		{
			if (atomicCount[0] > 1)
				formula << "H" << atomicCount[0];
			else if (atomicCount[0] == 1)
				formula << "H";
			
			atomicCount[0] = 0;
		}
	}
	for (int j = 0; j < NumElements; j++)
	{
		if (atomicCount[ alphabetical[j]-1 ] > 1)
			formula << etab.GetSymbol(alphabetical[j]) 
				<< atomicCount[ alphabetical[j]-1 ];
		else if (atomicCount[ alphabetical[j]-1 ] == 1)
			formula << etab.GetSymbol( alphabetical[j] );
	}
}
