import {
    thash;
    ihash;
    i8hash;
    i16hash;
    i32hash;
    i64hash;
    nhash;
    n8hash;
    n16hash;
    n32hash;
    n64hash;
    bhash;
    lhash;
    phash;
} "mo:map/Map";
import Map "mo:map/Map";
import Prelude "mo:base/Prelude";
import XorShift "mo:rand/XorShift";
import ULIDAsyncSource "mo:ulid/async/Source";
import ULIDSource "mo:ulid/Source";
import ULID "mo:ulid/ULID";
import Datatypes "types/datatype";

module {

    type AttributeDataType = Datatypes.AttributeDataType;
    type AttributeDataValue = Datatypes.AttributeDataValue; 

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    private func getHash(attributeDataValue: AttributeDataValue) : Nat32 {

        var hash : Nat32 = 0;

        switch (attributeDataValue) {
            case (#text(value)) hash := thash.0(value);
            case (#int(value)) hash := ihash.0(value);
            case (#int8(value)) hash := i8hash.0(value);
            case (#int16(value)) hash := i16hash.0(value);
            case (#int32(value)) hash := i32hash.0(value);
            case (#int64(value)) hash := i64hash.0(value);
            case (#nat(value)) hash := nhash.0(value);
            case (#nat8(value)) hash := n8hash.0(value);
            case (#nat16(value)) hash := n16hash.0(value);
            case (#nat32(value)) hash := n32hash.0(value);
            case (#nat64(value)) hash := n64hash.0(value);
            case (#blob(value)) hash := bhash.0(value);
            case (#bool(value)) hash := lhash.0(value);
            case (#principal(value)) hash := phash.0(value);
            case (_) Prelude.nyi();
        };

        return hash;
    };

    private func areEqual(attributeDataValue1: AttributeDataValue, attributeDataValue2: AttributeDataValue) : Bool {

        var areEqual : Bool = false;

        switch (attributeDataValue1) {
            case (#text(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#text(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#int(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int8(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#int8(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int16(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#int16(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int32(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#int32(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#int64(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#int64(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#nat(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat8(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#nat8(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat16(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#nat16(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat32(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#nat32(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#nat64(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#nat64(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#blob(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#blob(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#bool(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#bool(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (#principal(attributeValue1)) {
                switch (attributeDataValue2) {
                    case (#principal(attributeValue2)) areEqual := attributeValue1 == attributeValue2;
                    case (_) Prelude.unreachable();
                };
            };
            case (_) {
                Prelude.unreachable();
            };
        };

        return areEqual;
    };

    public let DataTypeValueHashUtils : Map.HashUtils<AttributeDataValue> = (getHash, areEqual);

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    public func generateULIDSync() : Text {

        ULID.toText(ULIDSource.Source(XorShift.toReader(XorShift.XorShift64(null)), 123).new());
    };

    public func generateULIDAsync() : async Text {

        ULID.toText(await ULIDAsyncSource.Source(0).new());
    };

    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

};