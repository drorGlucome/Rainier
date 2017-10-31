#include <stdio.h>
#include "general.h"

NSString* RelativeDate(NSDate* date)
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    return [dateFormatter stringFromDate:date];
}

NSString* HourAsComponentOfDay(int h)
{
    if(h >= 6 && h < 11)
        return loc(@"morning");
    else if(h >= 11 && h < 16)
        return loc(@"noon");
    else if(h >= 16 && h < 18)
        return loc(@"afternoon");
    else if(h >= 18 && h < 22)
        return loc(@"evening");
    else if(h >= 22 || h < 2)
        return loc(@"night");
    else if(h >= 2 && h < 6)
        return loc(@"midnight");
    
    return @"";
}


NSString* rails2iosTimeFromDate(NSDate* date)
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    NSString* tmp = [dateFormatter stringFromDate:date];
    if(tmp == nil) {
        return @"N/A";
    }
    NSString* res = [[NSString alloc] initWithString:tmp];
    return res;
}


/*NSString* rails2iosTime(NSString* text)
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [dateFormatter dateFromString:text];
    
    return rails2iosTimeFromDate(date);
}*/


NSString* rails2iosDateFromDate(NSDate* date)
{
    NSDate *now = [NSDate date];
    NSDate *yesterday = [now dateByAddingTimeInterval:-1*24*60*60];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    NSString* res = [dateFormatter stringFromDate:date];
    NSString* nowRes = [dateFormatter stringFromDate:now];
    NSString* yesterdayRes = [dateFormatter stringFromDate:yesterday];
    
    if([res isEqualToString:nowRes]) {
        return loc(@"Today");
    }
    if([res isEqualToString:yesterdayRes]) {
        return loc(@"Yesterday");
    }
    
    return res;
}

/*NSString* rails2iosDate(NSString* text)
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];

    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [dateFormatter dateFromString:text];
    
    return rails2iosDateFromDate(date);
}*/

NSString* NSDate2rails(NSDate* date) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString* dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

NSDate* rails2iosNSDate(NSString* text) {
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    NSDate* date = [dateFormatter dateFromString:text];
    return date;
}

UIColor* socialPositionToColor(int position, int numberOfPeople)
{
    double percentile = position * 1.0 / numberOfPeople;
    
    if(numberOfPeople == 1)return GREEN;
    else if(numberOfPeople == 2)
    {
        if (percentile < 0.5) return GREEN;
        return RED;
    }
    else {
        if (percentile < 0.34) return GREEN;
        if (percentile < 0.67) return YELLOW;
        return RED;
    }
}

UIColor* foodToColor(int value)
{
    switch (value) {
        case 1:
            return GREEN;
        case 2:
            return GREEN;
        case 3:
            return GREEN;
        default:
            return GREEN;
            break;
    }
}

UIColor* weightToColor(int value)
{
    return GRAY;
}
UIColor* activityToColor(int value)
{
    switch (value) {
        case 1:
            return GREEN;
        case 2:
            return GREEN;
        case 3:
            return GREEN;
        default:
            return GREEN;
            break;
    }
}

glucose_type glucoseToType(int glucose, int tag)//always mg/dl   //0-low, 1-normal, 2-high, 3-very high
{
    int value = glucose;
    int upperLimit = 120;
    int lowerLimit = 70;
    
    NSString* target_key = @"";
    if(tag < 0 || tag % 2 == 0) //before x
        target_key = profile_pre_meal_target;
    else
        target_key = profile_post_meal_target;
    
    NSString* upperStr = [[NSUserDefaults standardUserDefaults] objectForKey:target_key];
    if(upperStr != nil) {
        upperLimit = [upperStr intValue];
    }
    NSString* lowerStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_hypo_threshold];
    if(lowerStr != nil) {
        lowerLimit = [lowerStr intValue];
    }
    
    if(value == 0) {
        return 2;
    }
    int ranges[5] = {0,lowerLimit,upperLimit, upperLimit*MAX_TOLERANCE, 10000};
    for(int i = 0; i < 4; i++) {
        if(value >= ranges[i] && value < ranges[i+1]) {
            return i;
        }
    }
    return 2;
    
}

UIColor* glucoseToColor(int glucose, int tag) //always mg/dl
{
    UIColor* colors[4] = {BLUE, GREEN, YELLOW, RED};
    
    return colors[glucoseToType(glucose, tag)];
}


UIColor* stripsToColor(NSString* strips) {
    NSScanner *scanner = [NSScanner scannerWithString:strips];
    BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
    if(!isNumeric) {
        return YELLOW;
    }

    int value = [strips intValue];
    if(value < 20) {
        return RED;
    }
    if(value < 40) {
        return YELLOW;
    }
    return GREEN;
}

UIColor* rateToColor(NSNumber* rate) {
    int value = [rate intValue];
    if(value < 50) {
        return RED;
    }
    if(value < 75) {
        return YELLOW;
    }
    return GREEN;
}


UIColor* measurementsToColor(NSString* rate) {
    int value = [rate intValue];
    if(value == 0) {
        return RED;
    }
    if(value < 4) {
        return YELLOW;
    }
    return GREEN;
}


UIColor* remindersToColor(NSString* rate) {
    int value = [rate intValue];
    if(value == 0) {
        return RED;
    }
    return GREEN;
}

UIColor* EHA1CToColor(NSNumber* value)
{
    int upperLimit = 120;
    int lowerLimit = 70;
    
    
    NSString* upperStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_upper_limit];
    if(upperStr != nil) {
        upperLimit = [upperStr intValue];
    }
    NSString* lowerStr = [[NSUserDefaults standardUserDefaults] objectForKey:profile_lower_limit];
    if(lowerStr != nil) {
        lowerLimit = [lowerStr intValue];
    }

    
    float f = [value floatValue];
    if(f < (lowerLimit + 46.7f) / 28.7f) {
        return BLUE;
    }
    if(f < (upperLimit + 46.7f) / 28.7f) {
        return GREEN;
    }
    if(f < (upperLimit*1.2 + 46.7f) / 28.7f) {
        return YELLOW;
    }
    return RED;
}



void gassert(bool cond, NSString* msg)
{
    @try {
        [NSException raise:NSInvalidArgumentException
                    format:@"%@",msg];
    } @catch (NSException *exception) {
        NSLog(@"GAssert: %@", msg);
        //[Crittercism logHandledException:exception];
    }
    
}

void breadbcrumb(NSString* msg) {
    double max_length = 130;
    int packets = ceilf([msg length]/max_length);
    for(int i=0;i<packets;i++) {
        int start = i*max_length;
        int end = MIN(max_length,[msg length] - max_length*i);
        NSString* tmp = [msg substringWithRange:NSMakeRange(start, end)];
        NSLog(@"breadbcrumb: %@", tmp);
        //[Crittercism leaveBreadcrumb:tmp];

    }
    
}

NSInteger binarySearchForFontSizeForLabel(UILabel * label, NSInteger minFontSize, NSInteger maxFontSize)
{
    CGSize constraintSize = CGSizeMake(label.frame.size.width, MAXFLOAT);
    do {
        // Set current font size
        UIFont* font = [UIFont fontWithName:label.font.fontName size:maxFontSize];
        
        // Find label size for current font size
        CGRect textRect = [[label text] boundingRectWithSize:constraintSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:font}
                                                     context:nil];
        
        CGSize labelSize = textRect.size;
        
        // Done, if created label is within target size
        if( labelSize.height <= label.frame.size.height )
            break;
        
        // Decrease the font size and try again
        maxFontSize -= 2;
        
    } while (maxFontSize > minFontSize);
    
    return maxFontSize;
}

NSString* NumberToFact(int i)
{
    
    NSArray* values =@[
                       @"0 is the atomic number of the theoretical element tetraneutron.",
                       @"1 is the number of dimensions of a line.",
                       @"2 is the number of polynucleotide strands in a DNA double helix.",
                       @"3 is the number of consecutive successful attempts in a hat trick in sports.",
                       @"4 is the number of chambers the mammalian heart consists of.",
                       @"5 is the number of basic \"pillars\" of Islam.",
                       @"6 is the standard length (year) of a term in office for a United States senator.",
                       @"7 is the number of periods, or horizontal rows of elements, in the periodic table.",
                       @"8 is the number of legs that arachnids have.",
                       @"9 is the number of circles of Hell in Dante's Divine Comedy.",
                       @"10 is the number of official inkblots in the Rorschach inkblot test.",
                       @"11 is the number of sides on the Canadian one-dollar coin (a hendecagon, an eleven-sided polygon).",
                       @"12 is the pairs of ribs normally in the human body.",
                       @"13 is the Youngest age a minor can rent or purchase a T rated game by the ESRB without parental (age 18 or older) consent.",
                       @"14 is the number of lines in a sonnet.",
                       @"15 is the approximate speed in miles per hour a penguin swims at.",
                       @"16 is the minimum age for getting an adult job in most states and provinces across the globe.",
                       @"17 is the maximum number of strokes of a Chinese radical.",
                       @"18 is the number of chapters into which James Joyce's epic novel Ulysses is divided.",
                       @"19 is the number of years in 235 lunations.",
                       @"20 is the number of baby teeth in the deciduous dentition.",
                       @"21 is the number of trump cards of the tarot deck if one does not consider The Fool to be a proper trump card.",
                       @"22 is the number of chapters of the Revelation of John in the Bible.",
                       @"23 is the number of chromosomes normal human sex cells have.",
                       @"24 is the number of frames per second at which motion picture film is usually projected.",
                       @"25 is the number of points needed to win a set in volleyball under rally scoring rules.",
                       @"26 is the number of letters in the English and Interlingua alphabets.",
                       @"27 is the number of moons of the planet Uranus.",
                       @"28 is the number of a car formerly run in the NASCAR Sprint Cup Series by Yates Racing.",
                       @"29 is the number of days it takes Saturn to orbit the Sun.",
                       @"30 is the number of variations in Bach's Goldberg Variations.",
                       @"31 is the number of flavors of Baskin-Robbins ice cream.",
                       @"32 is the number of completed, numbered piano sonatas by Ludwig van Beethoven.",
                       @"33 is the number of workers trapped, and also the number of survivors of the 2010 Copiapó mining accident.",
                       @"34 is the lucky number of Victor Pelevin's protagonist Stepan Mikhailov in the novel Numbers.",
                       @"35 is the minimum age of candidates for election to the United States Presidency.",
                       @"36 is the number of vehicles that run in each race of NASCAR's Camping World Truck Series.",
                       @"37 is the number of slots in European Roulette (numbered 0 through 36, the 00 is not used in European roulette as it is in American roulette).",
                       @"38 is the number of surviving plays written by William Shakespeare.",
                       @"39 is the number of books in the Old Testament according to Protestant canon.",
                       @"40 is the percentage of U.S. paper currency in circulation that was counterfeit by the end of the Civil War.",
                       @"41 is the age at which writer/director Tom Graeff (of Teenagers from Outer Space fame) committed suicide.",
                       @"42 is the number of US gallons in a barrel of oil.",
                       @"43 is the maximum number of cars participating in a NASCAR race in the Cup Series or Nationwide Series.",
                       @"44 is the percentage of kids who watch television before they go to sleep in the US.",
                       @"45 is the sapphire wedding anniversary in years of marriage.",
                       @"46 is the number of slices of pizza an average American kid eats in a year.",
                       @"47 is the number of El-Aurians Scotty manages to beam up before their ship is destroyed by the energy ribbon.",
                       @"48 is the number of Ptolemaic constellations.",
                       @"49 is the number of days and night Siddhartha Gautama spent meditating as a holy man.",
                       @"50 is the speed limit, in kilometers per hour, of Australian roads with unspecified limits.",
                       @"51 is the atomic number of antimony.",
                       @"52 is the number of white keys (notes in the C major scale).",
                       @"53 is the port number of UDP and TCP for the Domain Name System protocol.",
                       @"54 is the number of milligrams of caffeine Mountain Dew has.",
                       @"55 is the common speed limit for rural secondary roads and many urban freeways in many states of the United States.",
                       @"56 is the number of officially recognized ethnic groups in the list of ethnic groups in China.",
                       @"57 is the number of people at 20th Century Fox Studios died amid rioting and suicide.",
                       @"58 is the minimum wind speed (mph) needed to issue a Severe Thunderstorm Warning.",
                       @"59 is the number corresponding to the last second in a given minute.",
                       @"60 is the total number of cards in the game Racko.",
                       @"61 is the code for international direct dial phone calls to Australia.",
                       @"62 is the atomic number of samarium.",
                       @"63 is the number of chromosomes found in the offspring of a donkey and a horse.",
                       @"64 is the total number of black and white squares on the game board in chess or draughts.",
                       @"65 is the minimum grade required to pass an exam, or class, in many areas.",
                       @"66 is the number of hot dogs eaten by World record holder Joey Chestnut in 15 minutes.",
                       @"67 is the highest two-digit odd number not presently designating any highway in the Interstate Highway System of the United States.",
                       @"68 is the number of sectors on one cylinder of MFM hard disks with 4 heads and 17 sectors per track.",
                       @"69 is the number Bill and Ted were thinking of when talking to their future selves.",
                       @"70 is the number of years of marriage until the platinum wedding anniversary.",
                       @"71 is the atomic number of lutetium.",
                       @"72 is the number of names of God, according to Kabbalah.",
                       @"73 is the single-season home run record in baseball set by Barry Bonds in 2001.",
                       @"74 is the number of stars obtained by SpongeBob SquarePants in his driving school.",
                       @"75 is the age limit for Canadian senators.",
                       @"76 is the atomic number of osmium.",
                       @"77 is the atomic number of iridium.",
                       @"78 is the number of chromosomes in canine DNA.",
                       @"79 is the record for cumulative weeks at #1 on the Billboard charts, held by Elvis Presley.",
                       @"80 is the percentage of American men who say they would marry the same woman if they had it to do all over again.",
                       @"81 is the number of squares on a shogi playing board.",
                       @"82 is the number of games in an NBA or NHL regular season.",
                       @"83 is the atomic number of bismuth.",
                       @"84 is the atomic number of polonium.",
                       @"85 is the atomic number of astatine.",
                       @"86 is the device number for a lockout relay function in electrical circuit protection schemes.",
                       @"87 is the number of tools in the Wenger Swiss Army Knife version XXL, listed in the Guinness Book of World Records as the world's most multi-functional penknife.",
                       @"88 is the number of keys on a piano (36 black and 52 white).",
                       @"89 is the number of units of each colour in the board game Blokus.",
                       @"90 is the latitude of the North Pole and the South Pole.",
                       @"91 is the atomic number of protactinium.",
                       @"92 is the number of stories in the Xujiahui Tower proposed to be built in Shanghai, China.",
                       @"93 is that approximate distance in millions of miles the Sun is away from the Earth.",
                       @"94 is the atomic number of plutonium.",
                       @"95 is the atomic number of americium.",
                       @"96 is the rating of Skyrim on metacritic.com.",
                       @"97 is the number of leap days that the Gregorian calendar contains in its cycle of 400 years.",
                       @"98 is the highest jersey number allowed in the National Hockey League (as 99 was retired by the entire league to honor Wayne Gretzky).",
                       @"99 is the highest jersey number allowed in most major league sports.",
                       @"100 is the number of years in a century.",
                       @"101 is the number of the first check for new checking account in the US.",
                       @"102 is the atomic number of nobelium, an actinide.",
                       @"103 is the atomic number of lawrencium, an actinide.",
                       @"104 is the atomic number of rutherfordium.",
                       @"105 is the number of surat al-Fil in the Qur'an.",
                       @"106 is the atomic number of seaborgium (Unilhexium Unh).",
                       @"107 is the atomic number of bohrium.",
                       @"108 is there number of love sonnets in Astrophil and Stella, the first English sonnet sequence by Sir Philip Sidney.",
                       @"109 is the atomic number of meitnerium.",
                       @"110 is the number of stories of both towers of the former World Trade Center in New York.",
                       @"111 is the number occasionally referred to as \"eleventy-one\", as read in The Fellowship of the Ring by J.R.R.",
                       @"112 is the atomic number of the element copernicium (formerly called ununbium).",
                       @"113 is the intelligence Agency telephone number in Iran.",
                       @"114 is the number of chapters in the Quran.",
                       @"115 is the atomic number of an element temporarily called ununpentium.",
                       @"116 is the record for number of wins in a single season of Major League Baseball achieved by the Chicago Cubs in 1906 and the Seattle Mariners in 2001.",
                       @"117 is the atomic number of a recently discovered element temporarily called ununseptium.",
                       @"118 is the beginning of directory enquiries numbers in the United Kingdom,France, Germany, Latvia, Sweden, Ireland, and Turkey.",
                       @"119 is a number to report children / youth at risk in France.",
                       @"120 is the age at which Moses died.",
                       @"121 is the atomic number of the undiscovered chemical element Unbiunium.",
                       @"122 is the traffic emergency telephone number in China.",
                       @"123 is the atomic number of the yet-to-be-discovered element unbitrium.",
                       @"124 is the rank of the Palestinian territories in world population.",
                       @"125 is years in a quasquicentennial.",
                       @"126 is the atomic number of unbihexium, an element that has not yet been discovered.",
                       @"127 is the highest signed 8 bit integer.",
                       @"128 is the number of characters in the ASCII character set.",
                       @"129 is the number of episodes of the TV series Becker that ran on CBS from 1998 to 2004.",
                       @"130 is the approximate maximum height in meters of trees.",
                       @"131 is the number serving a monkiker for Indie music.",
                       @"132 is the rank of Uruguay in world population.",
                       @"133 is the number of career touchdowns from 1983 - 1996 of Canadian Football League quarterback Danny Barrett.",
                       @"134 is the rank of Mauritania in terms of world population.",
                       @"135 is the cartridge version of 35mm photographic film, used widely in still photogaphy.",
                       @"136 is the hottest temperature ever recorded in Fahrenheits at Aziziya, Libya in September 1922.",
                       @"137 is the atomic number of an element not yet observed called Untriseptium.",
                       @"138 is the number of touchdowns football quarterback Donnie Davis had for the Georgia Force of the Arena Football League.",
                       @"139 is the atomic number of Untriennium, an unsynthesized chemical element.",
                       @"140 is the character-entry limit for Twitter, a well-known characteristic of the service (based on the text messaging limit).",
                       @"141 is the number of participants (90 Indians and 51 Pilgrims) at the First Thanksgiving.",
                       @"142 is the number of 6-vertex planar graphs.",
                       @"143 is the number of episodes of the TV series The Adventures of Robin Hood on CBS from 1955 to 1959.",
                       @"144 is the Intel 8086 instruction for no operation (NOP).",
                       @"145 is the atomic number of Unquadpentium.",
                       @"146 is the Guinness World Record for the most languages a poem was recited in.",
                       @"147 is the highest possible break in snooker, in the absense of fouls and refereeing errors.",
                       @"148 is the number of episodes of the TV series The Fresh Prince of Bel-Air on NBC from 1990 to 1996.",
                       @"149 is the number of goals a Madagascar soccer team scored against itself after the coach argued a call, and players kicked the ball into their own net 149 times.",
                       @"150 is years in a sesquicentennial.",
                       @"151 is the number of episodes that TV series Malcolm in the Middle ran on the Fox Network from 2000 to 2006.",
                       @"152 is the number of diapers solder in a Pampers Swaddlers pack.",
                       @"153 is the ordinal number of the coat of arms of Komi Republic in the State Heraldic Register of the Russian Federation.",
                       @"154 is the period in days that the sun follows on gamma-ray flares.",
                       @"155 is the number of episodes the TV series Sea Hunt ran in syndication from 1958 to 1961.",
                       @"156 is the number of strikes a clock will strike in the course of a day.",
                       @"157 is the elevation in meters of Atalanti Island in the North Euboean Gulf of the Aegean Sea.",
                       @"158 is days it took for the Surprize ship that set sail from England on January 19, 1790, to make port in Port Jackson, Sydney, Australia on June 26, 158 days later.",
                       @"159 is the number of isomers of C11H24.",
                       @"160 is the number of characters permitted in a standard short message service in Australia and Europe.",
                       @"161 is the number of different ways to bet on a roulette wheel.",
                       @"162 is 162 is the total number of baseball games each team plays during a regular season in Major League Baseball.",
                       @"163 is the atomic number of an element temporarily called Unhextrium.",
                       @"164 is the number of episodes that the TV show The Adventures of Rin Tin Tin ran on ABC from 1954 to 1959.",
                       @"165 is the miles of Tahoe Rim Trail, a long-distance hiking trail around Lake Tahoe.",
                       @"166 is the number of athletes (104 men and 62 women) that represented Scotland in the 2006 Commonwealth Games in Melbourne, Australia.",
                       @"167 is the number of tennis titles that Martina Navratilova has, which is an all-time record for men or women.",
                       @"168 is the number of triples that Shoeless Joe Jackson hit in his MLB career.",
                       @"169 is the height in feet of The Oak Island Lighthouse on Oak Island, North Carolina.",
                       @"170 is largest integer for which Google\"s built-in calculator function can compute the factorial.",
                       @"171 is the rank of Bahamas in world population.",
                       @"172 is the record in miles per hour of John White's shot in squash.",
                       @"173 is the atomic number of an element temporarily called Unsepttrium.",
                       @"174 is the atomic number of an element temporarily called Unseptquadium.",
                       @"175 is the number of weeks that professional golfer David Toms spent in the top-10 of the Official World Golf Rankings between 2001 and 2006.",
                       @"176 is the rank of Rocks (1976) by Aerosmith on Rolling Stone magazine's list of the 500 Greatest Albums of All Time.",
                       @"177 is the all-time titles record held by Tennis Hall of Famer Martina Navratilova.",
                       @"178 is the rank of Estonia in world population density.",
                       @"179 is the rank of the Anthology 1961-1977 (1992) by Curtis Mayfield and The Impressions on Rolling Stone magazine's list of the 500 greatest albums of all time.",
                       @"180 is the number of litres of saliva in one day that cattle can produce.",
                       @"181 is the number of 181 colleges, universities and other higher education institutions in Texas.",
                       @"182 is the carat of the Star of Bombay cabochon-cut star sapphire originating from Sri Lanka.",
                       @"183 is the id number of Issam Hamid Al Bin Ali Al Jayfi, a detainee at Guantanamo Bay.",
                       @"184 is a number believed to be a magic number in nuclear physics.",
                       @"185 is the distance a single playing card was thrown in feet by Kevin St. Onge to set a Guinness World Record.",
                       @"186 is the atomic number of an element temporarily called Unocthexium.",
                       @"187 is the atomic number of an element temporarily called Unoctseptium.",
                       @"188 is the rank of Tonga in world population.",
                       @"189 is the number of irregular verbs in the English language (from \"abide\" to \"write\").",
                       @"190 is the rank of Uruguay in population density.",
                       @"191 is the atomic number of an element temporarily called Unennunium.",
                       @"192 is the length in miles of the The Coast to Coast Walk in England.",
                       @"193 is species of monkeys and apes.",
                       @"194 is the number of historic building in the Braden Castle Park Historic District in Bradenton, Florida.",
                       @"195 is the rank of BNY Mellon Center in terms of the tallest skyscraper in the world.",
                       @"196 is the length of the Adda River in Italy.",
                       @"197 is the number of years that Fu Xi lived for altogether.",
                       @"198 is the number of sacks by Reggie White in his NFL career from 1985-2000.",
                       @"199 is the number of hits by Ron Davis in his MLB career from 1962-1969.",
                       @"200 is the minimum number of varieties of watermelons grown in the U.S.",
                       @"201 is the HTTP status code indicating a new resource was successfully created in response to the request.",
                       @"202 is the HTTP status code indicating the request was accepted but has not yet been fulfilled.",
                       @"203 is the HTTP status code indicating partial information.",
                       @"204 is the HTTP status code indicating the request was received but there is no response to the request.",
                       @"205 is the world speed record (mph) of a car on ice.",
                       @"206 is the number of bones in the typical adult human body.",
                       @"207 is the area code for the US state of Maine.",
                       @"208 is the wavelength in meters of Radio Luxembourg's English language service from 1951 to 1991.",
                       @"209 is the basketball record for most three pointers in a row.",
                       @"210 is the world speed record (km/h) for a mountain bike on a ski slope.",
                       @"211 is the SMTP status code system status.",
                       @"212 is the area code for Manhattan, one of the original area codes, and considered the most coveted in America.",
                       @"213 is the radical meaning \"turtle\", one of only two of the 214 Kangxi radicals that are composed of 16 strokes.",
                       @"214 is the first area code of metropolitan Dallas, Texas.",
                       @"215 is the Dewey Decimal Classification for Science and religion.",
                       @"216 is the ISO's standard for paper sizes.",
                       @"217 is the room in Stephen King's novel \"The Shining\", that plays a central part in the story as it is haunted.",
                       @"218 is votes required in the US House of Representatives to achieve a majority as of 2008.",
                       @"219 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"220 is the common voltage in many countries.",
                       @"221 is sMTP status code for service closing transmission channel.",
                       @"222 is the number for Historical Books of the Old Testament in the Dewey Decimal System.",
                       @"223 is an uninteresting number.",
                       @"224 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"225 is the longest distance in miles a deepwater lobster has been recorded to travel.",
                       @"226 is a boring number.",
                       @"227 is the number of days Pi Patel was at sea in the popular novel, Life of Pi.",
                       @"228 is an unremarkable number.",
                       @"229 is the lowest individual batting score not achieved by any player in test match cricket.",
                       @"230 is the common voltage in the European Union.",
                       @"231 is the number of cubic inches in a U.S. liquid gallon.",
                       @"232 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"233 is a boring number.",
                       @"234 is a boring number.",
                       @"235 is the number of three interstate highways in the United States, located in the states of Iowa, Kansas, and Oklahoma.",
                       @"236 is a boring number.",
                       @"237 is a boring number.",
                       @"238 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"239 is the atomic mass number of the most common isotope of plutonium.",
                       @"240 is distinct solutions of the Soma cube puzzle.",
                       @"241 is an uninteresting number.",
                       @"242 is the rumored time for the release of Radiohead's pre-sale for their 2012 tour.",
                       @"243 is the number of Earth Days for the planet Venus to complete one Venetian day, one revolution.",
                       @"244 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"245 is the number of Jewish singers who returned from captivity in Babylon in circa 538 BCE BC following the rise of Cyrus the Great and the Persian Empire.",
                       @"246 is a boring number.",
                       @"247 is an uninteresting number.",
                       @"248 is the number of organs in the human body as traditionally depicted.",
                       @"249 is a boring number.",
                       @"250 is the number of Pokémon originally available in Pokémon Gold and Silver before Celebi was added.",
                       @"251 is the number of Pokémon available in Pokémon Gold and Silver is 251.",
                       @"252 is an uninteresting number.",
                       @"253 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"254 is an uninteresting number.",
                       @"255 is the largest values that can be assigned to elements in the 24-bit RGB color model, since each color channel is allotted eight bits.",
                       @"256 is the number of NFL regular season football games.",
                       @"257 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"258 is a boring number.",
                       @"259 is an unremarkable number.",
                       @"260 is a boring number.",
                       @"261 is number of possible unfolded tesseract patterns.",
                       @"262 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"263 is a boring number.",
                       @"264 is an uninteresting number.",
                       @"265 is an unremarkable number.",
                       @"266 is a boring number.",
                       @"267 is the number of groups of order 64.",
                       @"268 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"269 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"270 is the average number of days in human pregnancy.",
                       @"271 is a boring number.",
                       @"272 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"273 is the death toll of the air crash of American Airlines Flight 191.",
                       @"274 is a boring number.",
                       @"275 is an uninteresting number.",
                       @"276 is the highest number of rounds in boxing history, in a bare-knuckle fight in 1825 that saw Jack Jones beat Patsy Tunney after 4hr 30min.",
                       @"277 is a boring number.",
                       @"278 is an unremarkable number.",
                       @"279 is a boring number.",
                       @"280 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"281 is a boring number.",
                       @"282 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"283 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"284 is a boring number.",
                       @"285 is the total number of Rules of Acquisition in Star Trek.",
                       @"286 is an unremarkable number.",
                       @"287 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"288 is an unremarkable number.",
                       @"289 is a boring number.",
                       @"290 is a boring number.",
                       @"291 is a boring number.",
                       @"292 is an unremarkable number.",
                       @"293 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"294 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"295 is the numerical designation of seven circumfrental or half-circumfrental routes of Interstate 95 in the United States.",
                       @"296 is a boring number.",
                       @"297 is an uninteresting number.",
                       @"298 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"299 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"300 is the approximate number of Spartans who fought to death at the Battle of Thermopylae.",
                       @"301 is an uninteresting number.",
                       @"302 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"303 is a boring number.",
                       @"304 is the record number of wickets taken in English cricket season by Tich Freeman in 1928.",
                       @"305 is an unremarkable number.",
                       @"306 is an uninteresting number.",
                       @"307 is an uninteresting number.",
                       @"308 is an uninteresting number.",
                       @"309 is an unremarkable number.",
                       @"310 is a boring number.",
                       @"311 is a boring number.",
                       @"312 is an unremarkable number.",
                       @"313 is the number of Muslims who fought in the Battle of Badr against Muhammad's, and by extension, Islam's, foes.",
                       @"314 is an unremarkable number.",
                       @"315 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"316 is an uninteresting number.",
                       @"317 is a boring number.",
                       @"318 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"319 is an uninteresting number.",
                       @"320 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"321 is an uninteresting number.",
                       @"322 is an unremarkable number.",
                       @"323 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"324 is a boring number.",
                       @"325 is an unremarkable number.",
                       @"326 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"327 is an unremarkable number.",
                       @"328 is the weight in pounds of an ovarian cyst removed from a woman in Galveston, Texas, in 1905, a world record.",
                       @"329 is a boring number.",
                       @"330 is an uninteresting number.",
                       @"331 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"332 is an uninteresting number.",
                       @"333 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"334 is the long-time highest score in Test cricket (held by Sir Donald Bradman and Mark Taylor).",
                       @"335 is an unremarkable number.",
                       @"336 is the number of dimples on an American golf ball.",
                       @"337 is an uninteresting number.",
                       @"338 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"339 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"340 is an uninteresting number.",
                       @"341 is an uninteresting number.",
                       @"342 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"343 is the speed of sound in dry air at 20 °C (68 °F) in m/s.",
                       @"344 is a boring number.",
                       @"345 is a boring number.",
                       @"346 is an uninteresting number.",
                       @"347 is an uninteresting number.",
                       @"348 is an uninteresting number.",
                       @"349 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"350 is the number of cubic inches displaced in the most common form of the Small Block Chevrolet V8.",
                       @"351 is an uninteresting number.",
                       @"352 is the number of international appearances by Kristine Lilly for the USA women's national soccer team, an all-time record.",
                       @"353 is an uninteresting number.",
                       @"354 is an uninteresting number.",
                       @"355 is a boring number.",
                       @"356 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"357 is an uninteresting number.",
                       @"358 is an unremarkable number.",
                       @"359 is an unremarkable number.",
                       @"360 is the number of degrees in a circle for the purpose of angular measurement.",
                       @"361 is the number of positions on a standard 19 x 19 Go board.",
                       @"362 is a boring number.",
                       @"363 is an uninteresting number.",
                       @"364 is the total number of gifts received in the song \"The Twelve Days of Christmas\".",
                       @"365 is the number of solar days in the mean tropical year.",
                       @"366 is the number of days in a leap year.",
                       @"367 is a boring number.",
                       @"368 is a boring number.",
                       @"369 is a boring number.",
                       @"370 is a boring number.",
                       @"371 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"372 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"373 is an uninteresting number.",
                       @"374 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"375 is an unremarkable number.",
                       @"376 is an uninteresting number.",
                       @"377 is an unremarkable number.",
                       @"378 is an unremarkable number.",
                       @"379 is an uninteresting number.",
                       @"380 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"381 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"382 is an uninteresting number.",
                       @"383 is the cubic displacement in inches of a 350cid Small Block Chevrolet with a 400cid SBC crankshaft.",
                       @"384 is the apogee (farthest distance from Earth) of the expeditions to the International Space Station in km.",
                       @"385 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"386 is the number of Pokémon in the 3rd Generation National Pokédex.",
                       @"387 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"388 is an unremarkable number.",
                       @"389 is a boring number.",
                       @"390 is the speed in feet per second that nerve impulses for muscle position travel at.",
                       @"391 is a boring number.",
                       @"392 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"393 is an unremarkable number.",
                       @"394 is an uninteresting number.",
                       @"395 is an uninteresting number.",
                       @"396 is the displacement in cubic inches of early Chevrolet Big-Block engines.",
                       @"397 is an unremarkable number.",
                       @"398 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"399 is a boring number.",
                       @"400 is the number of years in a period of the Gregorian calendar, of which 97 are leap years and 303 are common.",
                       @"401 is an uninteresting number.",
                       @"402 is an unremarkable number.",
                       @"403 is an uninteresting number.",
                       @"404 is the HTTP status code for \"Not found\", perhaps the most famous HTTP status code.",
                       @"405 is an unremarkable number.",
                       @"406 is an unremarkable number.",
                       @"407 is a boring number.",
                       @"408 is a boring number.",
                       @"409 is a boring number.",
                       @"410 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"411 is an uninteresting number.",
                       @"412 is an unremarkable number.",
                       @"413 is an uninteresting number.",
                       @"414 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"415 is an unremarkable number.",
                       @"416 is an unremarkable number.",
                       @"417 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"418 is the error code for \"I'm a teapot\" in the Hyper Text Coffee Pot Control Protocol.",
                       @"419 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"420 is a boring number.",
                       @"421 is an uninteresting number.",
                       @"422 is an uninteresting number.",
                       @"423 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"424 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"425 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"426 is an unremarkable number.",
                       @"427 is an unremarkable number.",
                       @"428 is an uninteresting number.",
                       @"429 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"430 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"431 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"432 is three-dozen sets of a dozen, making it three gross.",
                       @"433 is the perfect score in the game show Fifteen To One, only ever achieved once in over 2000 shows.",
                       @"434 is an unremarkable number.",
                       @"435 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"436 is an uninteresting number.",
                       @"437 is an unremarkable number.",
                       @"438 is an unremarkable number.",
                       @"439 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"440 is the standard frequency in hertz to which most orchestras tune the pitch A above middle C.",
                       @"441 is the number of squares on a Super Scrabble board.",
                       @"442 is a boring number.",
                       @"443 is an uninteresting number.",
                       @"444 is a boring number.",
                       @"445 is an uninteresting number.",
                       @"446 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"447 is an uninteresting number.",
                       @"448 is an uninteresting number.",
                       @"449 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"450 is a perfect score in Canadian five-pin bowling.",
                       @"451 is the temperature at which the paper in books ignites, giving the name to Ray Bradbury's novel Fahrenheit 451.",
                       @"452 is a boring number.",
                       @"453 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"454 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"455 is an uninteresting number.",
                       @"456 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"457 is an unremarkable number.",
                       @"458 is a boring number.",
                       @"459 is an uninteresting number.",
                       @"460 is a boring number.",
                       @"461 is a boring number.",
                       @"462 is an uninteresting number.",
                       @"463 is the number of days in the synodic period of Ceres.",
                       @"464 is the number of legal positions of the kings in chess, not counting mirrored positions.",
                       @"465 is a boring number.",
                       @"466 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"467 is an uninteresting number.",
                       @"468 is an uninteresting number.",
                       @"469 is a boring number.",
                       @"470 is the minimum length in yards from the tee to the hole on a Par 5.",
                       @"471 is an uninteresting number.",
                       @"472 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"473 is an uninteresting number.",
                       @"474 is an unremarkable number.",
                       @"475 is a boring number.",
                       @"476 is an uninteresting number.",
                       @"477 is a boring number.",
                       @"478 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"479 is a boring number.",
                       @"480 is the number of hours for rocking non-stop in a rocking chair, a world record held by Dennis Easterling of Atlanta.",
                       @"481 is an uninteresting number.",
                       @"482 is an uninteresting number.",
                       @"483 is an unremarkable number.",
                       @"484 is a boring number.",
                       @"485 is an unremarkable number.",
                       @"486 is an unremarkable number.",
                       @"487 is an uninteresting number.",
                       @"488 is a boring number.",
                       @"489 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"490 is the number of Pokémon available as of the release of Pokémon Diamond and Pearl (excluding event Pokémon).",
                       @"491 is a boring number.",
                       @"492 is an unremarkable number.",
                       @"493 is the number of Pokémon species, from the first set through the fourth generation as of August 2009.",
                       @"494 is a boring number.",
                       @"495 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"496 is what the dimension of the gauge group must be for a superstring theory to make sense.",
                       @"497 is an unremarkable number.",
                       @"498 is an unremarkable number.",
                       @"499 is a boring number.",
                       @"500 is the longest advertised distance of the IndyCar Series and its premier race, the Indianapolis 500.",
                       @"501 is an unremarkable number.",
                       @"502 is a boring number.",
                       @"503 is an unremarkable number.",
                       @"504 is an unremarkable number.",
                       @"505 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"506 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"507 is a boring number.",
                       @"508 is an uninteresting number.",
                       @"509 is a boring number.",
                       @"510 is a boring number.",
                       @"511 is the number of collaborators mathematician Paul Erdős had.",
                       @"512 is an unremarkable number.",
                       @"513 is an unremarkable number.",
                       @"514 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"515 is an uninteresting number.",
                       @"516 is an uninteresting number.",
                       @"517 is an uninteresting number.",
                       @"518 is an uninteresting number.",
                       @"519 is an unremarkable number.",
                       @"520 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"521 is an unremarkable number.",
                       @"522 is an uninteresting number.",
                       @"523 is a boring number.",
                       @"524 is a boring number.",
                       @"525 is the number of scan lines in the NTSC television standard.",
                       @"526 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"527 is a boring number.",
                       @"528 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"529 is an unremarkable number.",
                       @"530 is an unremarkable number.",
                       @"531 is an uninteresting number.",
                       @"532 is an unremarkable number.",
                       @"533 is a boring number.",
                       @"534 is a boring number.",
                       @"535 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"536 is the number of ways to arrange the pieces of the stomachion puzzle into a square, not counting rotation or reflection.",
                       @"537 is an uninteresting number.",
                       @"538 is the total number of votes in the Electoral College of the United States.",
                       @"539 is an uninteresting number.",
                       @"540 is an uninteresting number.",
                       @"541 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"542 is an unremarkable number.",
                       @"543 is an unremarkable number.",
                       @"544 is a boring number.",
                       @"545 is a boring number.",
                       @"546 is an unremarkable number.",
                       @"547 is an unremarkable number.",
                       @"548 is a boring number.",
                       @"549 is a boring number.",
                       @"550 is the number of accidents per day that falling asleep while driving results in in the United States on average.",
                       @"551 is an unremarkable number.",
                       @"552 is an unremarkable number.",
                       @"553 is an unremarkable number.",
                       @"554 is an uninteresting number.",
                       @"555 is the number of keyboard sonatas written by Domenico Scarlatti, according to the catalog by Ralph Kirkpatrick.",
                       @"556 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"557 is an unremarkable number.",
                       @"558 is an uninteresting number.",
                       @"559 is an unremarkable number.",
                       @"560 is a boring number.",
                       @"561 is an unremarkable number.",
                       @"562 is the number of Native American (including Alaskan) Nations, or \"Tribes,\" recognized by the USA government.",
                       @"563 is an uninteresting number.",
                       @"564 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"565 is an uninteresting number.",
                       @"566 is an unremarkable number.",
                       @"567 is a boring number.",
                       @"568 is a boring number.",
                       @"569 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"570 is an unremarkable number.",
                       @"571 is an unremarkable number.",
                       @"572 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"573 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"574 is a boring number.",
                       @"575 is a boring number.",
                       @"576 is an uninteresting number.",
                       @"577 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"578 is an uninteresting number.",
                       @"579 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"580 is an unremarkable number.",
                       @"581 is an unremarkable number.",
                       @"582 is an uninteresting number.",
                       @"583 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"584 is a boring number.",
                       @"585 is an uninteresting number.",
                       @"586 is an uninteresting number.",
                       @"587 is the outgoing port for email message submission.",
                       @"588 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"589 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"590 is a boring number.",
                       @"591 is an uninteresting number.",
                       @"592 is an uninteresting number.",
                       @"593 is an unremarkable number.",
                       @"594 is an uninteresting number.",
                       @"595 is an unremarkable number.",
                       @"596 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"597 is a boring number.",
                       @"598 is an uninteresting number.",
                       @"599 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"600 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"601 is the location of the first occurrence of 3 consecutive zeroes in the decimal digits of p.",
                       @"602 is an uninteresting number.",
                       @"603 is the smallest number n so that n, n+1, and n+2 are all the product of a prime and the square of a prime.",
                       @"604 is a boring number.",
                       @"605 is an uninteresting number.",
                       @"606 is the first non-trivial number that is both 11-gonal and centered 11-gonal.",
                       @"607 is the exponent of a Mersenne prime.",
                       @"608 is a number that does not have any digits in common with its cube.",
                       @"609 is a strobogrammatic number.",
                       @"610 is the smallest Fibonacci number that begins with 6.",
                       @"611 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"612 is a number whose square and cube use different digits.",
                       @"613 is the index of a prime Lucas number.",
                       @"614 is the smallest number that can be written as the sum of 3 squares in 9 ways.",
                       @"615 is the trinomial coefficient T(10,6).",
                       @"616 is an unremarkable number.",
                       @"617 is 1!^{2} + 2!^{2} + 3!^{2} + 4!^{2}.",
                       @"618 is the number of ternary square-free words of length 15.",
                       @"619 is a strobogrammatic prime.",
                       @"620 is the number of sided 7-hexes.",
                       @"621 is the number of ways to 9-color the faces of a tetrahedron.",
                       @"622 is an uninteresting number.",
                       @"623 is the number of inequivalent asymmetric Ferrers graphs with 23 points.",
                       @"624 is the smallest number with the property that its first 5 multiples contain the digit 2.",
                       @"625 is an automorphic number.",
                       @"626 is a palindrome in base 5 and in base 10.",
                       @"627 is the number of partitions of 20.",
                       @"628 is the sum of the squares of 4 consecutive primes.",
                       @"629 is an uninteresting number.",
                       @"630 is a triangular number, 3 times a triangular number, and 6 times a triangular number.",
                       @"631 is an uninteresting number.",
                       @"632 is the number of triangles formed by connecting the diagonals of a regular octagon.",
                       @"633 is the smallest number n whose 5^{th} root has a decimal part that begins with the digits of n.",
                       @"634 is a number n whose 5^{th} root has a decimal part that begins with the digits of n.",
                       @"635 is a number n whose 5^{th} root has a decimal part that begins with the digits of n.",
                       @"636 is a number n whose 5^{th} root has a decimal part that begins with the digits of n.",
                       @"637 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"638 is the number of fixed 5-kings.",
                       @"639 is a number n whose 5^{th} root has a decimal part that begins with the digits of n.",
                       @"640 is a boring number.",
                       @"641 is the smallest prime factor of 2^{2^{5}}+1.",
                       @"642 is the smallest number with the property that its first 6 multiples contain the digit 2.",
                       @"643 is the largest prime factor of 123456.",
                       @"644 is an uninteresting number.",
                       @"645 is the largest n for which 1+2+3+ ... +n = 1^{2}+2^{2}+3^{2}+ ... +k^{2} for some k.",
                       @"646 is the number of connected planar graphs with 7 vertices.",
                       @"647 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"648 is the smallest number whose decimal part of its 6^{th} root begins with the digits 1-9 in some order.",
                       @"649 is the smallest number n so that n^{2} is 1 more than 13 times a square.",
                       @"650 is the sum of the first 12 squares.",
                       @"651 is an uninteresting number.",
                       @"652 is the only known non-perfect number whose number of divisors and sum of smaller divisors are perfect.",
                       @"653 is the only known prime for which 5 is neither a primitive root or a quadratic residue of 4n^{2}+1.",
                       @"654 is an uninteresting number.",
                       @"655 is an uninteresting number.",
                       @"656 is a palindrome in base 3 and in base 10.",
                       @"657 is the number of ways to tile a 4×22 rectangle with 4×1 rectangles.",
                       @"658 is the number of triangles of any size contained in the triangle of side 13 on a triangular grid.",
                       @"659 is an Eisenstein-Mersenne prime.",
                       @"660 is the order of a non-cyclic simple group.",
                       @"661 is the largest prime factor of 8!.",
                       @"662 is the index of the smallest triangular number that contains the digits 1, 2, 3, 4, and 5.",
                       @"663 is the generalized Catalan number C(15,3).",
                       @"664 is a value of n so that n(n+7) is a palindrome.",
                       @"665 is a member of the Fibonacci-type sequence starting with 1 and 4.",
                       @"666 is the largest rep-digit triangular number.",
                       @"667 is the maximal number of regions into which 36 lines divide a plane.",
                       @"668 is the number of legal pawn moves in Chess.",
                       @"669 is the number of unsymmetrical ways to dissect a regular 12-gon into 10 triangles.",
                       @"670 is an octahedral number.",
                       @"671 is a rhombic dodecahedral number.",
                       @"672 is a multi-perfect number.",
                       @"673 is a Tetranacci-like number starting from 1, 1, 1, and 1.",
                       @"674 is an uninteresting number.",
                       @"675 is the smallest order for which there are 17 groups.",
                       @"676 is the smallest palindromic square number whose square root is not palindromic.",
                       @"677 is the closest integer to 11^{e}.",
                       @"678 is a member of the Fibonacci-type sequence starting with 1 and 7.",
                       @"679 is the smallest number with multiplicative persistence 5.",
                       @"680 is the smallest tetrahedral number that is also the sum of 2 tetrahedral numbers.",
                       @"681 is an unremarkable number.",
                       @"682 is _{11}C_{6} + _{11}C_{8} + _{11}C_{2}.",
                       @"683 is a number for which we're missing a fact (submit one to numbersapi at google mail!).",
                       @"684 is the sum of 3 consecutive cubes.",
                       @"685 is an unremarkable number.",
                       @"686 is the number of partitions of 35 in which no part occurs only once.",
                       @"687 is the closest integer to 8^{p}.",
                       @"688 is a boring number.",
                       @"689 is the smallest number that can be written as the sum of 3 distinct squares in 9 ways.",
                       @"690 is the smallest number that can not be written as the sum of a triangular number, a cube, and a Fibonacci number.",
                       @"691 is the smallest prime p for which x^{5} = x^{4} + x^{3} + x^{2} + x + 1 (mod p) has 5 solutions.",
                       @"692 is a number that does not have any digits in common with its cube.",
                       @"693 is a boring number.",
                       @"694 is the number of different arrangements (up to rotation and reflection) of 7 non-attacking rooks on a 7×7 chessboard.",
                       @"695 is the maximum number of pieces a torus can be cut into with 15 cuts.",
                       @"696 is a palindrome n so that n(n+8) is also palindromic.",
                       @"697 is a 12-hyperperfect number.",
                       @"698 is 3^{2} + 4^{3} + 5^{4}.",
                       @"699 is a value of n for which |cos(n)| is smaller than any previous integer.",
                       @"700 is the number of symmetric 8-cubes."
                       ];
    
    if(i >= values.count || i < 0) return @"keep on the good work";
    
    NSString* result = [values objectAtIndex:i];
    
    if([result containsString:@"missing a fact"])
    {
        return @"keep on the good work";
    }
        
    return [values objectAtIndex:i];

}