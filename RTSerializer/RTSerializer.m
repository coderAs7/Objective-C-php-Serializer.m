//
//  RTSerializer.m
//  RuvixTel
//
//  Created by Hasintha on 3/21/13.
//  Copyright (c) 2013 Tharindu Madushanka. All rights reserved.
//

#import "RTSerializer.h"



@interface RTSerializer(){
	int _pos;
}

@end

@implementation RTSerializer



-(NSString *)serialize:(id)object inString:(NSString *)str{
	
	
	if([object isKindOfClass:[NSArray class]]){
		NSArray *a = (NSArray *)object;
		str= [str stringByAppendingFormat:@"a:%d:{",(int)[a count]];
		
		for (int i = 0; i < [a count]; i++)
		{
			[self serialize:[NSNumber numberWithInt:i] inString:str];
			[self serialize:[a objectAtIndex:i] inString:str];
			
		}
		str=[str stringByAppendingString:@"{"];
		
		return str;
	}
	else if([object isKindOfClass:[NSNumber class]]){
		int i = [(NSNumber *)object intValue];
		return [str stringByAppendingFormat:@"i:%d;",i];
	}
	else if([object isKindOfClass:[NSDictionary class]]){
		NSDictionary *a = (NSDictionary *)object;
		str= [str stringByAppendingFormat:@"a:%d:{",(int)[[a allKeys]count]];
		
		for (NSString *key in [a allKeys])
		{
			str= [self serialize:key inString:str];
			str= [self serialize:[a valueForKey:key] inString:str];
			
		}
		str=[str stringByAppendingFormat:@"}"];
		
		return str;
	}
	else if([object isKindOfClass:[NSString class]]){
		return [str stringByAppendingFormat:@"s:%d:\"%@\";",(int)[(NSString *)object length],(NSString *)object];
		
		
	}
	else{
		return str;
	}
}

-(id)deserialize:(NSString *)str withStringEncoding:(NSStringEncoding)stringEncoding {
	NSData *data = [str dataUsingEncoding:stringEncoding];
	
	NSString *encodedString = [[NSString alloc] initWithData:data encoding:[NSString defaultCStringEncoding]];
	return [self deserialize:encodedString];
}


-(id)deserialize:(NSString *)str {
	if(str == nil || [str length]<=_pos)
		return nil;
	
	NSUInteger start,end,length;
	
	NSString *strLen;
	
	unichar character = [str characterAtIndex:_pos];
	switch (character) {
		case 'N':
			_pos+=2;
			return nil;
			break;
		case 's':{
			
			NSRange starRange=[str rangeOfString:@":" options:0 range:NSMakeRange(_pos, [str length]-_pos)];
			start=starRange.location+1;
			
			NSRange endRange =[str rangeOfString:@":" options:0 range:NSMakeRange(start, [str length]-start)];
			end=endRange.location;
			
			
			strLen = [str substringWithRange:NSMakeRange(start, end-start)];
			int bytelen = strLen.intValue;
			length = bytelen;
			
			if ((end + 2 + length) >= [str length]) length = [str length] - 2 - end;
			NSString *stRet = [str substringWithRange:NSMakeRange(end+2, length)];
			
			_pos+=6+strLen.length+length;
			
			NSData *data = [stRet dataUsingEncoding:[NSString defaultCStringEncoding]];
			NSString *utf8String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
			return utf8String;
		}
		case 'i':{
			NSString *stInt;
			NSRange starRange=[str rangeOfString:@":" options:0 range:NSMakeRange(_pos, [str length]-_pos)];
			start=starRange.location+1;
			
			NSRange endRange =[str rangeOfString:@";" options:0 range:NSMakeRange(start, [str length]-start)];
			end=endRange.location;
			
			
			stInt = [str substringWithRange:NSMakeRange(start, end -start)];
			_pos += 3 + [stInt length];
			return @([stInt integerValue]);
		}
		case 'a':{
			NSRange starRange=[str rangeOfString:@":" options:0 range:NSMakeRange(_pos, [str length]-_pos)];
			start=starRange.location+1;
			
			NSRange endRange =[str rangeOfString:@":" options:0 range:NSMakeRange(start, [str length]-start)];
			end=endRange.location;
			
			strLen=[str substringWithRange:NSMakeRange(start, end-start)];
			length=strLen.intValue;
			
			NSMutableArray *alRet=[[NSMutableArray alloc]initWithCapacity:length];
			NSMutableDictionary *htRect=[[NSMutableDictionary alloc]initWithCapacity:length];
			
			_pos+=4+strLen.length;
			
			for(int i=0;i<length;i++){
				id key=[self deserialize:str];
				id value = [self deserialize:str];
				if(!value) value = [NSNull null];
				
				if(alRet != nil){
					if([key isKindOfClass:[NSString class]] && [key rangeOfCharacterFromSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]].location == NSNotFound && [key intValue]==alRet.count)
						[alRet addObject:value];
					else
						alRet=nil;
				}
				
				[htRect setValue:value forKey:key];
			}
			
			_pos++;
			
			if (_pos < [str length] && [str characterAtIndex:_pos] == ';')
				_pos++;
			if (alRet != nil)
				return alRet;
			else
				return htRect;
		}
			
		default:
			break;
	}
	return nil;
}


@end
