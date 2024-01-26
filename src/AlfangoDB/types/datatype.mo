module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type DefaultAttributeDataType = {
        #default;
    };
    public type DefaultAttributeDataValue = {
        #default;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type NumericAttributeDataType = {
        #int;
        #int8;
        #int16;
        #int32;
        #int64;
        #nat;
        #nat8;
        #nat16;
        #nat32;
        #nat64;
        #float;
    };

    public type NumericAttributeDataValue = {
        #int : Int;
        #int8 : Int8;
        #int16 : Int16;
        #int32 : Int32;
        #int64 : Int64;
        #nat : Nat;
        #nat8 : Nat8;
        #nat16 : Nat16;
        #nat32 : Nat32;
        #nat64 : Nat64;
        #float : Float;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type StringAttributeDataType = {
        #text;
        #char;
    };

    public type StringAttributeDataValue = {
        #text : Text;
        #char : Char;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ListAttributeDataType = {
        #list;
    };

    public type ListAttributeDataValue = {
        #list : [ NumericAttributeDataValue or StringAttributeDataValue ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type MiscAttributeDataType = {
        #bool;
        #blob;
        #principal;
        #map;
    };

    public type MiscAttributeDataValue = {
        #bool : Bool;
        #blob : Blob;
        #principal : Principal;
        #map : [ (Text, NumericAttributeDataValue or StringAttributeDataValue or ListAttributeDataValue) ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AttributeDataType = DefaultAttributeDataType or NumericAttributeDataType or StringAttributeDataType or ListAttributeDataType or MiscAttributeDataType;

    public type AttributeDataValue = DefaultAttributeDataValue or NumericAttributeDataValue or StringAttributeDataValue or ListAttributeDataValue or MiscAttributeDataValue;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
};