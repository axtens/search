MODULE Search;
FROM Files IMPORT Open, READ, Close;
FROM XDOS IMPORT BlockReadCreate, BlockReadDestroy, BlockReadLine;
FROM DevIO IMPORT WriteOut, LineOut, NLOut, CardOut;
FROM System IMPORT Terminate, GetArg;
FROM Directories IMPORT NORMAL, DirQuery, DirEntry;
FROM Strings IMPORT Assign, Pos;
FROM XString IMPORT RightTrim, UpperCase;
FROM Storage IMPORT ALLOCATE, DEALLOCATE;
VAR
   sTemp,
   sInFile,
   sSearch : ARRAY [0..63] OF CHAR;
   cTemp     : CARDINAL;
   bFlag     : BOOLEAN;

PROCEDURE instruct;
BEGIN
     LineOut('Search InputFile/s searchstring');
     Terminate(2);

END instruct;

PROCEDURE SearchFor( direntry : DirEntry);
TYPE
    tBigString = ARRAY [0..2048] OF CHAR;
    pBig      = POINTER TO tBigString;
VAR
        sRecord,
        sRecordCopy : pBig;
        cInLength,
        cInCount : CARDINAL;
        iBuf : INTEGER;
BEGIN
     NEW(sRecord);
     NEW(sRecordCopy);
     bFlag := TRUE;
     cInCount := 0;
     WriteOut('Scanning ');
     WriteOut(direntry.name);
     WriteOut(' for ');
     LineOut(sSearch);
     Open(iBuf,direntry.name,READ);
     BlockReadCreate(32767);
     BlockReadLine(iBuf,sRecord^,cInLength);
     WHILE cInLength>0 DO
          RightTrim( sRecord^);
          INC(cInCount);
          Assign(sRecord^,sRecordCopy^);
          UpperCase(sRecordCopy^);
          IF (Pos(sSearch,sRecordCopy^) <= HIGH(sRecordCopy^)) THEN
              WriteOut('[');
              CardOut(cInCount,5);
              WriteOut(']');
              LineOut(sRecord^)
          END;
          BlockReadLine(iBuf,sRecord^,cInLength);
     END;
     Close(iBuf);
     BlockReadDestroy;
     NLOut;
     DISPOSE(sRecord);
     DISPOSE(sRecordCopy);
END SearchFor;

BEGIN
     GetArg(sTemp,cTemp);
     IF cTemp=0 THEN
      instruct;
     END;
     Assign(sTemp,sInFile);
     GetArg(sTemp,cTemp);
     IF cTemp=0 THEN
        LineOut('no Search text');
        instruct
     END;
     UpperCase(sTemp);
     Assign(sTemp,sSearch);
     bFlag := FALSE;
     DirQuery(sInFile,NORMAL,SearchFor);
     IF NOT bFlag THEN
      LineOut('no files found');
      Terminate(2)
     ELSE
         Terminate(1)
     END;
END Search.


