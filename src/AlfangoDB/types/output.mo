import Datatypes "datatype";
import Database "database";
import SearchTypes "search";
import Result "mo:base/Result";

module {

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type CreateDatabaseOutputType = Result.Result<{}, [ Text ]>;

    public type CreateTableOutputType = Result.Result<{}, [ Text ]>;

    public type CreateItemOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type GetTableMetadataOutputType = ?{
        databaseName: Text;
        tableName: Text;
        metadata : Database.TableMetadata;
    };

    public type GetItemByIdOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type ScanOutputType = Result.Result<[{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }], [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    

    public type UpdateItemOutputType = Result.Result<{ id : Text; item: [ (Text, Datatypes.AttributeDataValue) ] }, [ Text ]>;

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public type UpdateOpsOutputType = {
        #CreateDatabaseOutput : CreateDatabaseOutputType;
        #CreateTableOutput : CreateTableOutputType;
        #CreateItemOutput : CreateItemOutputType;
        #UpdateItemOutput : UpdateItemOutputType;
    };

    public type QueryOpsOutputType = {
        #GetTableMetadataOutput : GetTableMetadataOutputType;
        #GetItemByIdOutput : GetItemByIdOutputType;
        #ScanOutput : ScanOutputType;
    };

};