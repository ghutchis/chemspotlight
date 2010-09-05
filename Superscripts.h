/**********************************************************************
Superscripts.h - Define UTF-8 superscripts for chemical formulas

Copyright (C) 2005-2006 by Geoffrey R. Hutchison

***********************************************************************/

// superscript + and -
#define UTF8_SUP_PLUS "\xE2\x81\xBA"
#define UTF8_SUP_MINUS "\xE2\x81\xBB"

// superscript numerals
#define UTF8_SUP_0 "\xE2\x81\xB0"
#define UTF8_SUP_1 "\xC2\xB9"
#define UTF8_SUP_2 "\xC2\xB2"
#define UTF8_SUP_3 "\xC2\xB3"
#define UTF8_SUP_4 "\xE2\x81\xB4"
#define UTF8_SUP_5 "\xE2\x81\xB5"
#define UTF8_SUP_6 "\xE2\x81\xB6"
#define UTF8_SUP_7 "\xE2\x81\xB7"
#define UTF8_SUP_8 "\xE2\x81\xB8"
#define UTF8_SUP_9 "\xE2\x81\xB9"

// a bunch of constant strings for the display formula's superscrips
const CFStringRef supP = CFStringCreateWithCString(NULL, UTF8_SUP_PLUS, kCFStringEncodingUTF8);
const CFStringRef supM = CFStringCreateWithCString(NULL, UTF8_SUP_MINUS, kCFStringEncodingUTF8);
const CFStringRef sup0 = CFStringCreateWithCString(NULL, UTF8_SUP_0, kCFStringEncodingUTF8);
const CFStringRef sup1 = CFStringCreateWithCString(NULL, UTF8_SUP_1, kCFStringEncodingUTF8);
const CFStringRef sup2 = CFStringCreateWithCString(NULL, UTF8_SUP_2, kCFStringEncodingUTF8);
const CFStringRef sup3 = CFStringCreateWithCString(NULL, UTF8_SUP_3, kCFStringEncodingUTF8);
const CFStringRef sup4 = CFStringCreateWithCString(NULL, UTF8_SUP_4, kCFStringEncodingUTF8);
const CFStringRef sup5 = CFStringCreateWithCString(NULL, UTF8_SUP_5, kCFStringEncodingUTF8);
const CFStringRef sup6 = CFStringCreateWithCString(NULL, UTF8_SUP_6, kCFStringEncodingUTF8);
const CFStringRef sup7 = CFStringCreateWithCString(NULL, UTF8_SUP_7, kCFStringEncodingUTF8);
const CFStringRef sup8 = CFStringCreateWithCString(NULL, UTF8_SUP_8, kCFStringEncodingUTF8);
const CFStringRef sup9 = CFStringCreateWithCString(NULL, UTF8_SUP_9, kCFStringEncodingUTF8);

void ReplaceSuperscripts(CFMutableStringRef displayFormula)
{
  CFStringFindAndReplace(displayFormula, CFSTR("+"), supP, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("-"), supM, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("0"), sup0, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("1"), sup1, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("2"), sup2, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("3"), sup3, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("4"), sup4, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("5"), sup5, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("6"), sup6, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("7"), sup7, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("8"), sup8, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	CFStringFindAndReplace(displayFormula, CFSTR("9"), sup9, CFRangeMake(0, CFStringGetLength(displayFormula)), 0);
	
	return;
}
