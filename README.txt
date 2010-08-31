ChemSpotlight 2.0   README
--------------------------

ChemSpotlight is a Spotlight metadata importer plugin for Mac OS X 10.4 or later, which reads common chemical file formats (MDL .mol, .mdl, .sd, .sdf, Tripos .mol2, PDB, Chemical Markup Language, XYZ), etc. using the Open Babel chemistry library. It is provided as a Universal Binary.

It expects the Open Babel 2.3 chemistry library (including headers) to be installed into
 /usr/local/lib which should be the default when you compile from source yourself or install from the ChemSpotlight package.

The main metadata importer code is in GetMetadataForFile.mm -- an Objective-C++ file. (It resembles fairly standard C++ code with the exception of some Apple CoreFoundation code to interface with Spotlight.)

Copyright (C) 2005-2010 by Geoffrey R. Hutchison

More questions, comments, complaints? Please e-mail me at <geoff.hutchison@gmail.com> or visit the ChemSpotlight website:
http://chemspotlight.openmolecules.net

This project is part of the Open Babel project.
For more information, see <http://openbabel.org/>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation version 2 of the License.
