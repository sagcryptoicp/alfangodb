import Database "database";
import Datatypes "datatype";

module {

    public type CreateDatabaseInputType = {
        name : Text;
    };

    public type CreateTableInputType = {
        databaseName : Text;
        name : Text;
        attributes : [ Database.AttributeMetadata ];
        indexes : [ Database.TableIndexMetadata ];
    };

    public type CreateItemInputType = {
        databaseName : Text;
        tableName : Text;
        attributesDataValues: [ (Text, Datatypes.AttributeDataValue) ];
    };

    public type GetItemByIdInputType = {
        databaseName: Text;
        tableName: Text;
        id: Text;
    };

};