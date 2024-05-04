import Datatypes "datatype";
import Database "database";
import Result "mo:base/Result";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type CreateDatabaseOutputType = Result.Result<{}, [ Text ]>;

    public type CreateTableOutputType = Result.Result<{}, [ Text ]>;

    public type CreateItemOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type TableMetadataOutputType = {
        attributes : [ Database.AttributeMetadata ];
        indexes : [ Database.TableIndexMetadata ];
    };

    public type GetTableMetadataOutputType = ?{
        databaseName: Text;
        tableName: Text;
        metadata : TableMetadataOutputType;
    };

    public type GetItemByIdOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ScanOutputType = Result.Result<[{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }], [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

    public type AddAttributeOutputType = Result.Result<{ databaseName : Text; tableName : Text; attributeName : Text; }, [ Text ]>;

    public type DropAttributeOutputType = Result.Result<{ databaseName : Text; tableName : Text; attributeName : Text; }, [ Text ]>;

    public type UpdateItemOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type UpdateOpsOutputType = {
        #CreateDatabaseOutput : CreateDatabaseOutputType;
        #CreateTableOutput : CreateTableOutputType;
        #AddAttributeOutput : AddAttributeOutputType;
        #DropAttributeOutput : DropAttributeOutputType;
        #CreateItemOutput : CreateItemOutputType;
        #UpdateItemOutput : UpdateItemOutputType;
    };

    public type QueryOpsOutputType = {
        #GetTableMetadataOutput : GetTableMetadataOutputType;
        #GetItemByIdOutput : GetItemByIdOutputType;
        #ScanOutput : ScanOutputType;
    };

};