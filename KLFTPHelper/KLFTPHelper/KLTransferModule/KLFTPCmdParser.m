//
//  KLFTPCmdParser.m
//  KLFTPHelper
//


#import "KLFTPCmdParser.h"

@interface KLFTPCmdParser()

@property (nonatomic, strong) NSMutableString  * readBuffer;
@property (nonatomic, weak) id<KLFTPCmdParserDelegate>  delegate;


@end

@implementation KLFTPCmdParser


- (id)initWithDelegate: ( id<KLFTPCmdParserDelegate> )delegate{
    self.delegate = delegate;
    self.readBuffer = [[NSMutableString alloc] initWithCapacity:256];
    return self;
}

- (void)parseString:(NSString *)str {
    
    int slen = [str length];
    int clen = [self.readBuffer length];
    NSError *error;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern: @"^[1-5][0-9]{2} .*$" options:NSRegularExpressionAnchorsMatchLines error:&error];
    if (clen + slen < 256){
        [self.readBuffer appendString:str];
        NSRange   searchedRange = NSMakeRange(0, [self.readBuffer length]);
        NSArray* matches = [regex matchesInString:self.readBuffer options:0 range:searchedRange];
        NSTextCheckingResult * lastMatch = nil;
        for (NSTextCheckingResult* match in matches) {
            lastMatch = match;
            NSString* matchText = [self.readBuffer substringWithRange:[match range]];
            [self.delegate klFTPCmdParser:self didParsedServerResponse:matchText];
        }
        if( lastMatch ){
            NSRange lastRange = [lastMatch range];
            int skipIndex = lastRange.location + lastRange.length;
            if( skipIndex < [self.readBuffer length] ){
                [self.readBuffer setString:[self.readBuffer substringFromIndex:skipIndex]];
            }
            else{
                [self.readBuffer setString:@""];
            }
        }
        else{
            [self.delegate parserNeedMoreData:self];
        }
    }
    else{
        // ASSERT HERE
    }
}

@end
