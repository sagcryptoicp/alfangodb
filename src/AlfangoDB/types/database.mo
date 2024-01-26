import Datatypes "datatype";
import Map "mo:map/Map";
import Set "mo:map/Set";
import Time "mo:base/Time";

module {

    type AttributeDataType = Datatypes.AttributeDataType;
    type AttributeDataValue = Datatypes.AttributeDataValue;

    public type Id = Text;
    public type DatabaseName = Text;
    public type AttributeName = Text;
    public type IndexName = Text;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type AttributeMetadata = {
        name :  AttributeName;
        dataType : AttributeDataType;
        unique : Bool;
        required : Bool;
        defaultValue : AttributeDataValue;
    };

    public type TableIndexMetadata = {
        name : IndexName;
        nonUnique : Bool;
        attributeName : Text;
    };

    public type TableMetadata = {
        attributes : [ AttributeMetadata ];
        indexes : [ TableIndexMetadata ];
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type Item = {
        id : Id;
        attributeDataValueMap : Map.Map<AttributeName, AttributeDataValue>;
        previousAttributeDataValueMap : Map.Map<AttributeName, AttributeDataValue>;
        createdAt : Time.Time;
        var updatedAt : Time.Time;
    };

    public type Index = {
        items : Map.Map<AttributeDataValue, Set.Set<Id>>;
    };

    public type Table = {
        name : Text;
        metadata : TableMetadata;
        items : Map.Map<Id, Item>;
        indexes : Map.Map<AttributeName, Index>;        // single attribute indexes
    };

    public type Database = {
        name : DatabaseName;
        tables : Map.Map<Text, Table>;
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public class AlfangoDB() {
        public let databases : Map.Map<DatabaseName, Database> = Map.new<DatabaseName, Database>();
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
};