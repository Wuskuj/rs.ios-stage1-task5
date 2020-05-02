#import "Converter.h"

// Do not change
NSString *KeyPhoneNumber = @"phoneNumber";
NSString *KeyCountry = @"country";

@implementation PNConverter
- (NSDictionary*)converToPhoneNumberNextString:(NSString*)string; {
    
    NSDictionary *dictCode = @{
        @"77" : @"KZ",
        @"79" : @"RU",
        @"373" : [NSArray arrayWithObjects:@"MD", @8, nil],
        @"374" : [NSArray arrayWithObjects:@"AM", @8, nil],
        @"375" : [NSArray arrayWithObjects:@"BY", @9, nil],
        @"380" : [NSArray arrayWithObjects:@"UA", @9, nil],
        @"992" : [NSArray arrayWithObjects:@"TJ", @9, nil],
        @"993" : [NSArray arrayWithObjects:@"TM", @8, nil],
        @"994" : [NSArray arrayWithObjects:@"AZ", @9, nil],
        @"996" : [NSArray arrayWithObjects:@"KG", @9, nil],
        @"998" : [NSArray arrayWithObjects:@"UZ", @9, nil]
        
    };
    
    NSDictionary *dictLenghtNumber = @{
        @8 : @"(xx) xxx-xxx",
        @9 : @"(xx) xxx-xx-xx",
        @10 : @"(xxx) xxx-xx-xx"
    };
    
    NSString *plus = [[string substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"] ? @"" : @"+";
    
    if ([string length] == 1) {
        return @{KeyPhoneNumber: [NSString stringWithFormat:@"%@%@",plus,string],
                 KeyCountry: dictCode[@"79"]};
    }
    
    NSMutableString *replaceString = nil;
    NSString *numberWithoutCode;
    NSString *firstTwoElements = [string substringWithRange:NSMakeRange(0, 2)];
    NSArray *allKeysArray = [dictCode allKeys];
    NSArray *sortedKeysArray = [allKeysArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        if ([a intValue] < [b intValue]) return NSOrderedAscending;
        else return NSOrderedDescending;
    }];
        if ([firstTwoElements isEqualToString:[sortedKeysArray firstObject]] || [firstTwoElements isEqualToString:sortedKeysArray[1]]) {
            KeyCountry = dictCode[firstTwoElements];
            replaceString = [dictLenghtNumber[@10] mutableCopy];
            numberWithoutCode = [string substringFromIndex:1];
            replaceString = [self phoneNumberConverter:string replaceString:replaceString substringToIndex:1 insertString:[NSString stringWithFormat:@"%@7 ",plus]];
            return @{KeyPhoneNumber: replaceString,
                     KeyCountry: dictCode[firstTwoElements]};
        }
    
    if ([dictCode objectForKey:string] != nil) {
           return @{KeyPhoneNumber: [NSString stringWithFormat:@"%@%@",plus,string],
           KeyCountry: [[dictCode objectForKey:string] objectAtIndex:0]};
       }
    
    
    if (string.length < 3) {
        return @{KeyPhoneNumber :[NSString stringWithFormat: @"%@%@",plus,string],
                 KeyCountry: @""};
    }
    
    NSString *code = [string substringWithRange:NSMakeRange(0, 3)];
    NSArray *keyCodeArray = [dictCode objectForKey:code];
    NSString *keyCode = [keyCodeArray objectAtIndex:0];
    if (keyCode != nil) {
        int lengthNumber = [[keyCodeArray objectAtIndex:1] intValue];
        NSString *foundLengthNumber = [dictLenghtNumber objectForKey:[NSNumber numberWithInt:lengthNumber]];
        if (foundLengthNumber != nil) {
            replaceString = [[dictLenghtNumber objectForKey:[NSNumber numberWithInt:lengthNumber]] mutableCopy];
        } else {
            replaceString = [[dictLenghtNumber objectForKey:@8] mutableCopy];
        }
    } else {
        if (string.length > 12 && ![[string substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"+"]) {
            string = [string substringWithRange:NSMakeRange(0, 12)];
        }
        return @{KeyPhoneNumber :[NSString stringWithFormat: @"%@%@",plus,string],
        KeyCountry: @""};
    }
    
    replaceString = [self phoneNumberConverter:string replaceString:replaceString substringToIndex:keyCode.length + 1 insertString:[NSString stringWithFormat:@"%@%@ ",plus,code]];
    
    return @{KeyPhoneNumber: replaceString,
             KeyCountry: keyCode};
}



-(NSMutableString*)phoneNumberConverter:(NSString *)string replaceString:(NSMutableString*) replaceString substringToIndex:(NSInteger)index insertString:(NSString *)insertString {
    NSString *numberWithoutCode = [string substringFromIndex:index];
    int countForMainString = 0;
    for (int i = 0; i < replaceString.length; i++) {
        NSRange rangeForReplace = NSMakeRange(i, 1);
        NSRange rangeForMainString = NSMakeRange(countForMainString, 1);
        if ([[replaceString substringWithRange:rangeForReplace] isEqualToString:@"x"]){
            [replaceString replaceCharactersInRange:rangeForReplace withString:[numberWithoutCode substringWithRange:rangeForMainString]];
            countForMainString++;
        }
        if (countForMainString == [numberWithoutCode length]) {
            [replaceString deleteCharactersInRange:NSMakeRange(i + 1, [replaceString length] - (i + 1))];
            break;
        }
        
    }
    [replaceString insertString:insertString atIndex:0];
    return  replaceString;
}

@end
