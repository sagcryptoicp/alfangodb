import Datatypes "../types/datatype";
import Database "../types/database";
import Utils "../utils";
import HashMap "mo:base/HashMap";
import Option "mo:base/Option";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Map "mo:map/Map";
import Set "mo:map/Set";
import { thash } "mo:map/Map";

module {

    type AttributeDataType = Datatypes.AttributeDataType;
    type AttributeDataValue = Datatypes.AttributeDataValue;
    type Item = Database.Item;
    type AttributeName = Database.AttributeName;

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
            actualAttributeDataType;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func validateAttributeDataTypes({
        attributeKeyDataValues : [(Text, AttributeDataValue)];
        attributeNameToMetadataMap : HashMap.HashMap<Text, Database.AttributeMetadata>;
    }) : {
        isValidAttributesDataType : Bool;
    } {

        let unwantedAttributes = Buffer.Buffer<Text>(0);
        let invalidAttributes = Buffer.Buffer<Text>(0);

        for ((attributeName, attributeDataValue) in attributeKeyDataValues.vals()) {
            let attributeExistInTable = Option.isSome(attributeNameToMetadataMap.get(attributeName));
            var isValidAttributeDataType : Bool = false;

            if (attributeExistInTable) {
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
                    invalidAttributes.add(attributeName);
                    Debug.print("attribute: " # debug_show(attributeName) # " has invalid data type: " # debug_show(actualAttributeDataType));
                }
            } else {
                unwantedAttributes.add(attributeName);
                Debug.print("attribute: " # debug_show(attributeName) # " is not in table");
            };
        };

        return {
            isValidAttributesDataType = invalidAttributes.size() == 0 and unwantedAttributes.size() == 0;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func validateUniqueAttribute({
        attributeKeyDataValue : (AttributeName, AttributeDataValue);
        indexTable : Database.IndexTable;
    }) : Bool {

        let (attributeName, attributeDataValue) = attributeKeyDataValue;
        let indexItems = indexTable.items;

        var isValidUniqueAttribute = true;
        ignore do ?{
            let idSet = Map.get(indexItems, Utils.DataTypeValueHashUtils, attributeDataValue)!;
            if (Set.size(idSet) > 0) {
                isValidUniqueAttribute := false;
                Debug.print("attribute: " # debug_show(attributeKeyDataValue) # " is not unique");
            };
        };

        return isValidUniqueAttribute;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func validateUniqueAttributes({
        attributeKeyDataValues: [ (Text, Datatypes.AttributeDataValue) ];
        indexes: Map.Map<Text, Database.IndexTable>;
        tableMetadata: Database.TableMetadata;
    }) : {
        invalidUnquieAttributes : [ Text ];
        uniqueAttributesUnique : Bool;
    } {
        let attributesMetadata = tableMetadata.attributes;
        let attributeDataValueMap = HashMap.fromIter<Text, Datatypes.AttributeDataValue>(attributeKeyDataValues.vals(), 0, Text.equal, Text.hash);
        let invalidUnquieAttributes = Buffer.Buffer<Text>(0);

        label l0 for (attributeMetadata in attributesMetadata.vals()) {
            // check for unique attribute
            if (not attributeMetadata.unique) {
                continue l0;
            };

            let attributeName = attributeMetadata.name;
            ignore do ?{
                let attributeValue = attributeDataValueMap.get(attributeName)!;
                let isValidUniqueAttribute = validateUniqueAttribute({
                    attributeKeyDataValue = (attributeName, attributeValue);
                    indexTable = Map.get(indexes, thash, attributeName)!;
                });
                if (not isValidUniqueAttribute) {
                    invalidUnquieAttributes.add(attributeName);
                };
            };
        };

        return {
            invalidUnquieAttributes = Buffer.toArray(invalidUnquieAttributes);
            uniqueAttributesUnique = invalidUnquieAttributes.size() == 0;
        };
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

};