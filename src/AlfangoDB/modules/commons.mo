import Datatypes "../types/datatype";
import Database "../types/database";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Text "mo:base/Text";

module {

    type AttributeDataType = Datatypes.AttributeDataType;
    type AttributeDataValue = Datatypes.AttributeDataValue;
    type Item = Database.Item;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func unwrapAttributeDataValue({ attributeDataValue : AttributeDataValue }) : (AttributeDataType) {

        var unwrappedAttributeDataType : AttributeDataType = #default;

        switch (attributeDataValue) {
            case (#int(intValue)) { unwrappedAttributeDataType := #int32; };
            case (#int8(int8Value)) { unwrappedAttributeDataType := #int8; };
            case (#int16(int16Value)) { unwrappedAttributeDataType := #int16; };
            case (#int32(int32Value)) { unwrappedAttributeDataType := #int32; };
            case (#int64(int64Value)) { unwrappedAttributeDataType := #int64; };
            case (#nat(natValue)) { unwrappedAttributeDataType := #nat; };
            case (#nat8(nat8Value)) { unwrappedAttributeDataType := #nat8; };
            case (#nat16(nat16Value)) { unwrappedAttributeDataType := #nat16; };
            case (#nat32(nat32Value)) { unwrappedAttributeDataType := #nat32; };
            case (#nat64(nat64Value)) { unwrappedAttributeDataType := #nat64; };
            case (#float(floatValue)) { unwrappedAttributeDataType := #float; };
            case (#text(textValue)) { unwrappedAttributeDataType := #text; };
            case (#char(charValue)) { unwrappedAttributeDataType := #char; };
            case (#bool(boolValue)) { unwrappedAttributeDataType := #bool; };
            case (#principal(principalValue)) { unwrappedAttributeDataType := #principal; };
            case (#blob(blobValue)) { unwrappedAttributeDataType := #blob; };
            case (#list(listValue)) { unwrappedAttributeDataType := #list; };
            case (#map(mapValue)) { unwrappedAttributeDataType := #map; };
            case (#default) { unwrappedAttributeDataType := #default; };
        };

        return (unwrappedAttributeDataType);
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func validateAttributeDataType({ attributeDataValue : AttributeDataValue; expectedAttributeDataType : AttributeDataType }) : {
        isValidAttributeDataType : Bool;
        actualAttributeDataType : AttributeDataType;
    } {

        let actualAttributeDataType = unwrapAttributeDataValue({ attributeDataValue; });

        return {
            isValidAttributeDataType = (actualAttributeDataType == expectedAttributeDataType);
            actualAttributeDataType = actualAttributeDataType;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func validateAttributeDataTypeBulk({
        attributeDataValues : [(Text, AttributeDataValue)];
        attributeNameToMetadataMap : HashMap.HashMap<Text, Database.AttributeMetadata>;
    }) : {
        invalidDataTypeAttributeNameToExpectedDataType : HashMap.HashMap<Text, AttributeDataType>;
        isValidAttributesDataType : Bool;
    } {

        let invalidDataTypeAttributeNameToExpectedDataType = HashMap.HashMap<Text, AttributeDataType>(0, Text.equal, Text.hash);

        for ((attributeName, attributeDataValue) in attributeDataValues.vals()) {
            var expectedAttributeDataType : Datatypes.AttributeDataType = #default;
            ignore do ?{ expectedAttributeDataType := attributeNameToMetadataMap.get(attributeName)!.dataType };
            let {
                isValidAttributeDataType;
                actualAttributeDataType;
            } = validateAttributeDataType({
                attributeDataValue;
                expectedAttributeDataType;
            });

            if (not isValidAttributeDataType) {
                invalidDataTypeAttributeNameToExpectedDataType.put(attributeName, actualAttributeDataType);
            }
        };

        return {
            invalidDataTypeAttributeNameToExpectedDataType;
            isValidAttributesDataType = invalidDataTypeAttributeNameToExpectedDataType.size() == 0;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


};