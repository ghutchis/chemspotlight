/**********************************************************************
Subscripts.h - Define UTF-8 subscripts for chemical formulas

Copyright (C) 2005-2006 by Geoffrey R. Hutchison

This file is part of the Open Babel project.
For more information, see <http://openbabel.sourceforge.net/>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation version 2 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
***********************************************************************/

// subscript numerals in UTF8
#define UTF8_SUB_0 "\xE2\x82\x80"
#define UTF8_SUB_1 "\xE2\x82\x81"
#define UTF8_SUB_2 "\xE2\x82\x82"
#define UTF8_SUB_3 "\xE2\x82\x83"
#define UTF8_SUB_4 "\xE2\x82\x84"
#define UTF8_SUB_5 "\xE2\x82\x85"
#define UTF8_SUB_6 "\xE2\x82\x86"
#define UTF8_SUB_7 "\xE2\x82\x87"
#define UTF8_SUB_8 "\xE2\x82\x88"
#define UTF8_SUB_9 "\xE2\x82\x89"

// a bunch of constant strings for the display formula's subscripts
const CFStringRef sub0 = CFStringCreateWithCString(NULL, UTF8_SUB_0, kCFStringEncodingUTF8);
const CFStringRef sub1 = CFStringCreateWithCString(NULL, UTF8_SUB_1, kCFStringEncodingUTF8);
const CFStringRef sub2 = CFStringCreateWithCString(NULL, UTF8_SUB_2, kCFStringEncodingUTF8);
const CFStringRef sub3 = CFStringCreateWithCString(NULL, UTF8_SUB_3, kCFStringEncodingUTF8);
const CFStringRef sub4 = CFStringCreateWithCString(NULL, UTF8_SUB_4, kCFStringEncodingUTF8);
const CFStringRef sub5 = CFStringCreateWithCString(NULL, UTF8_SUB_5, kCFStringEncodingUTF8);
const CFStringRef sub6 = CFStringCreateWithCString(NULL, UTF8_SUB_6, kCFStringEncodingUTF8);
const CFStringRef sub7 = CFStringCreateWithCString(NULL, UTF8_SUB_7, kCFStringEncodingUTF8);
const CFStringRef sub8 = CFStringCreateWithCString(NULL, UTF8_SUB_8, kCFStringEncodingUTF8);
const CFStringRef sub9 = CFStringCreateWithCString(NULL, UTF8_SUB_9, kCFStringEncodingUTF8);

void ReplaceSubscripts(CFMutableStringRef displayFormula)
{
	CFStringFindAndReplace(displayFormula, CFSTR("0"), sub0, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("1"), sub1, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("2"), sub2, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("3"), sub3, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("4"), sub4, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("5"), sub5, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("6"), sub6, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("7"), sub7, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("8"), sub8, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("9"), sub9, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	
	return;
}