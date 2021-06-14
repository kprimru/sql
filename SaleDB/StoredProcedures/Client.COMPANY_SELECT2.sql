USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Client].[COMPANY_SELECT2]
    @SEARCH     NVarChar(MAX)       = NULL,
    @NAME       NVarChar(512)       = NULL,
    @NUMBER     NVarChar(MAX)       = NULL,
    @PHONE      NVarChar(128)       = NULL,
    @PERSONAL   NVarChar(256)       = NULL,
    @ACTIVITY   NVarChar(MAX)       = NULL,
    @PAY_CAT    NVarChar(MAX)       = NULL,
    @AREA       NVarChar(MAX)       = NULL,
    @STREET     NVarChar(MAX)       = NULL,
    @HOME       NVarChar(128)       = NULL,
    @ROOM       NVarChar(128)       = NULL,
    @AVAILAB    NVarChar(MAX)       = NULL,
    @SENDER     NVarChar(MAX)       = NULL,
    @WSTATE     NVarChar(MAX)       = NULL,
    @WSTATUS    NVarChar(MAX)       = NULL,
    @DBEGIN     SmallDateTime       = NULL,
    @DEND       SmallDateTime       = NULL,
    @POTENT     NVARCHAR(MAX)       = NULL,
    @MONTH      NVarChar(MAX)       = NULL,
    @TAXING     NVarChar(MAX)       = NULL,
    @SALE       NVarChar(MAX)       = NULL,
    @AGENT      NVarChar(MAX)       = NULL,
    @RIVAL      NVarChar(MAX)       = NULL,
    @CHARACTER  NVarChar(MAX)       = NULL,
    @REMOTE     NVarChar(MAX)       = NULL,
    @SELECT     Bit                 = NULL,
    @RC         Int                 = NULL OUTPUT,
    @MANAGER    NVarChar(MAX)       = NULL,
    @CARD       TINYINT             = NULL,
    @DELETED    Bit                 = NULL,
    @HISTORY    Bit                 = NULL,
    @RIVAL_PERS NVarChar(MAX)       = NULL,
    @CALL_BEGIN SmallDateTime       = NULL,
    @CALL_END   SmallDateTime       = NULL,
    @BLACK      Bit                 = NULL,
    @BLACK_NOTE NVarChar(128)       = NULL,
    @PROJECT    NVarChar(MAX)       = NULL,
    @EMAIL      NVarChar(256)       = NULL,
    @DEPO       Bit                 = NULL,
    @DEPO_NUM   NVarChar(MAX)       = NULL,
    @RIVALV     NVarChar(MAX)       = NULL,
    @ShowAll    Bit                 = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    DECLARE @company Table (ID  UniqueIdentifier Primary Key Clustered);
    DECLARE @rlist Table (ID  UniqueIdentifier Primary Key Clustered);
    DECLARE @wlist Table (ID  UniqueIdentifier Primary Key Clustered);
    DECLARE @tsearch Table(WRD VarChar(250) Primary Key Clustered);

    DECLARE
        @SearchWordCount    SmallInt;

    DECLARE @IdByFilterType Table
    (
        [Id]        UniqueIdentifier    NOT NULL,
        [Type]      TinyInt             NOT NULL
        Primary Key Clustered([Id], [Type])
    );

    DECLARE @UsedFilterTypes Table
    (
        [Type]      TinyInt NOT NULL
        Primary Key Clustered([Type])
    );

    DECLARE
        @FilterType_NUMBER      TinyInt,
        @FilterType_PHONE       TinyInt,
        @FilterType_PERSONAL    TinyInt,
        @FilterType_EMAIL       TinyInt,
        @FilterType_ACTIVITY    TinyInt,
        @FilterType_NAME        TinyInt,
        @FilterType_PAY_CAT     TinyInt,
        @FilterType_AREA        TinyInt,
        @FilterType_ADDRESS     TinyInt,
        @FilterType_AVAILABLE   TinyInt,
        @FilterType_SENDER      TinyInt,
        @FilterType_TAXING      TinyInt,
        @FilterType_WSTATE      TinyInt,
        @FilterType_WSTATUS     TinyInt,
        @FilterType_DATES       TinyInt,
        @FilterType_POTENTIAL   TinyInt,
        @FilterType_MONTH       TinyInt,
        @FilterType_SALE        TinyInt,
        @FilterType_RIVAL_PERS  TinyInt,
        @FilterType_MANAGER     TinyInt,
        @FilterType_AGENT       TinyInt,
        @FilterType_RIVAL       TinyInt,
        @FilterType_RIVALV      TinyInt,
        @FilterType_CHARACTER   TinyInt,
        @FilterType_REMOTE      TinyInt,
        @FilterType_PROJECT     TinyInt,
        @FilterType_CALL        TinyInt,
        @FilterType_BLACK       TinyInt,
        @FilterType_BLACK_NOTE  TinyInt,
        @FilterType_DEPO        TinyInt,
        @FilterType_DEPO_NUM    TinyInt,
        @FilterType_HISTORY     TinyInt,
        @FilterType_SELECTION   TinyInt;

        SET @FilterType_NUMBER      = 1;
        SET @FilterType_PHONE       = 2;
        SET @FilterType_PERSONAL    = 3;
        SET @FilterType_EMAIL       = 4;
        SET @FilterType_ACTIVITY    = 5;
        SET @FilterType_NAME        = 6;
        SET @FilterType_PAY_CAT     = 7;
        SET @FilterType_AREA        = 8;
        SET @FilterType_ADDRESS     = 9;
        SET @FilterType_AVAILABLE   = 10;
        SET @FilterType_SENDER      = 11;
        SET @FilterType_TAXING      = 12;
        SET @FilterType_WSTATE      = 13;
        SET @FilterType_WSTATUS     = 14;
        SET @FilterType_DATES       = 15;
        SET @FilterType_POTENTIAL   = 16;
        SET @FilterType_MONTH       = 17;
        SET @FilterType_SALE        = 18;
        SET @FilterType_RIVAL_PERS  = 19;
        SET @FilterType_MANAGER     = 20;
        SET @FilterType_AGENT       = 21;
        SET @FilterType_RIVAL       = 22;
        SET @FilterType_RIVALV      = 23;
        SET @FilterType_CHARACTER   = 24;
        SET @FilterType_REMOTE      = 25;
        SET @FilterType_PROJECT     = 26;
        SET @FilterType_CALL        = 27;
        SET @FilterType_BLACK       = 28;
        SET @FilterType_BLACK_NOTE  = 29;
        SET @FilterType_DEPO        = 30;
        SET @FilterType_DEPO_NUM    = 31;
        SET @FilterType_HISTORY     = 32;
        SET @FilterType_SELECTION   = 33;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT;



    BEGIN TRY
        IF @CARD = 0
            SET @CARD = NULL;

        IF @HISTORY IS NULL
            SET @HISTORY = 0;

        IF @HOME IS NOT NULL
        BEGIN
            SET @HOME = REPLACE(@HOME, '%', ' ');
            SET @HOME = LTRIM(RTRIM(@HOME));
        END

        IF @ShowAll = 1
            INSERT INTO @rlist(ID)
            SELECT ID
            FROM Client.Company
            WHERE STATUS = 1;
        ELSE
            INSERT INTO @rlist(ID)
            SELECT ID
            FROM Client.CompanyReadList();

        INSERT INTO @wlist(ID)
        SELECT ID
        FROM Client.CompanyWriteList();

        IF @DELETED = 1
            INSERT INTO @rlist(ID)
            SELECT ID
            FROM Client.Company
            WHERE STATUS = 3;

        IF @SEARCH IS NOT NULL
        BEGIN
            INSERT INTO @company(ID)
            SELECT ID
            FROM @rlist;

            INSERT INTO @tsearch(WRD)
            SELECT DISTINCT '%' + Word + '%'
            FROM Common.SplitString(@SEARCH);

            DELETE
            FROM @company
            WHERE ID IN
            (
                SELECT ID_COMPANY
                FROM Client.CompanyIndex
                WHERE EXISTS
                    (
                        SELECT *
                        FROM @tsearch
                        WHERE NOT (DATA LIKE WRD)
                    ) OR DATA IS NULL
            );

            IF @SELECT = 1
                DELETE FROM @company
                WHERE ID NOT IN
                    (
                        SELECT ID_COMPANY
                        FROM Client.CompanySelection
                        WHERE USR_NAME = ORIGINAL_LOGIN()
                    );
        END
        ELSE
        BEGIN
            IF @NUMBER IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID, @FilterType_NUMBER
                FROM Client.Company
                WHERE NUMBER IN
                    (
                        SELECT ITEM
                        FROM Common.IntTableFromList(@NUMBER , ',')
                    )
                    AND (STATUS = 1 OR STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_NUMBER)
            END;

            IF @PHONE IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID_COMPANY, @FilterType_PHONE
                FROM
                (
                    SELECT DISTINCT ID_COMPANY
                    FROM Client.CompanyPhone a
                    INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
                    WHERE PHONE_S LIKE @PHONE
                        AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1) AND a.STATUS = 1

                    UNION

                    SELECT DISTINCT c.ID
                    FROM Client.CompanyPersonal a
                    INNER JOIN Client.CompanyPersonalPhone b ON a.ID = b.ID_PERSONAL
                    INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                    WHERE b.PHONE_S LIKE @PHONE
                        AND a.STATUS = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1)
                ) AS A;

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_PHONE)
            END;

            IF @PERSONAL IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT b.ID, @FilterType_PERSONAL
                FROM Client.CompanyPersonal a
                INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
                WHERE FIO LIKE @PERSONAL
                    AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_PERSONAL)
            END;

            IF @EMAIL IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT b.ID, @FilterType_EMAIL
                FROM Client.CompanyPersonal a
                INNER JOIN Client.Company b ON a.ID_COMPANY = b.ID
                WHERE (a.EMAIL LIKE @EMAIL OR b.EMAIL LIKE @EMAIL)
                    AND a.STATUS = 1 AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1)

                UNION

                SELECT b.ID, @FilterType_EMAIL
                FROM Client.Company b
                WHERE (b.EMAIL LIKE @EMAIL)
                    AND (b.STATUS = 1 OR b.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_EMAIL)
            END;

            IF @NAME IS NOT NULL BEGIN
                INSERT INTO @tsearch(WRD)
                SELECT DISTINCT '%' + Word + '%'
                FROM Common.SplitString(@NAME);

                SET @SearchWordCount = (SELECT COUNT(*) FROM @tsearch);

                INSERT INTO @IdByFilterType
                SELECT ID, @FilterType_NAME
                FROM
                (
                    SELECT a.ID
                    FROM Client.CompanyActiveView a WITH(NOEXPAND)
                    WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
                        AND
                            (
                                SELECT Count(*)
                                FROM @tsearch AS T
                                WHERE a.NAME LIKE WRD
                            ) = @SearchWordCount

                    UNION

                    SELECT a.ID
                    FROM Client.CompanyActiveView a WITH(NOEXPAND)
                    INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
                    WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1
                        AND
                            (
                                SELECT Count(*)
                                FROM @tsearch AS T
                                WHERE a.NAME LIKE WRD
                            ) = @SearchWordCount
                ) AS A;

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_NAME)
            END;

            IF @ACTIVITY IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_ACTIVITY
                FROM Client.Company a
                INNER JOIN Client.CompanyActivity t ON t.ID_COMPANY = a.ID
                INNER JOIN Common.TableGUIDFromXML(@ACTIVITY) b ON t.ID_ACTIVITY = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_ACTIVITY)
            END;

            IF @PAY_CAT IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_PAY_CAT
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@PAY_CAT) b ON a.ID_PAY_CAT = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_PAY_CAT)
            END;

            IF @AREA IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_AREA
                FROM Client.Company a
                INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
                INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
                INNER JOIN Common.TableGUIDFromXML(@AREA) d ON c.ID_AREA = d.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1;

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_AREA)
            END;

            IF @STREET IS NOT NULL OR @HOME IS NOT NULL OR @ROOM IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_ADDRESS
                FROM Client.Company a
                INNER JOIN Client.Office b ON a.ID = b.ID_COMPANY
                INNER JOIN Client.OfficeAddress c ON c.ID_OFFICE = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1) AND b.STATUS = 1
                    AND (HOME = @HOME OR @HOME IS NULL)
                    AND (ROOM LIKE @ROOM OR @ROOM IS NULL)
                    AND (c.ID_STREET IN (SELECT ID FROM Common.TableGUIDFromXML(@STREET)) OR @STREET IS NULL);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_ADDRESS)
            END;

            IF @AVAILAB IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_AVAILABLE
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@AVAILAB) b ON a.ID_AVAILABILITY = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_AVAILABLE)
            END;

            IF @SENDER IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_SENDER
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@SENDER) b ON a.ID_SENDER = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_SENDER)
            END;

            IF @TAXING IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_TAXING
                FROM Client.Company a
                INNER JOIN Client.CompanyTaxing t ON t.ID_COMPANY = a.ID
                INNER JOIN Common.TableGUIDFromXML(@TAXING) b ON t.ID_TAXING = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_TAXING)
            END;

            IF @WSTATE IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_WSTATE
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@WSTATE) b ON a.ID_WORK_STATE = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_WSTATE)
            END;

            IF @WSTATUS IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_WSTATUS
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@WSTATUS) b ON a.ID_WORK_STATUS = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_WSTATUS)
            END;

            IF @DBEGIN IS NOT NULL OR @DEND IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_DATES
                FROM Client.Company a
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1)
                    AND (WORK_DATE >= @DBEGIN OR @DBEGIN IS NULL)
                    AND (WORK_DATE <= @DEND OR @DEND IS NULL);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_DATES)
            END;

            IF @POTENT IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_POTENTIAL
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@POTENT) b ON a.ID_POTENTIAL = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_POTENTIAL)
            END;

            IF @MONTH IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_MONTH
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@MONTH) b ON a.ID_NEXT_MON = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_MONTH)
            END;


            IF @SALE IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_SALE
                FROM Client.CompanyProcess a
                INNER JOIN Common.TableGUIDFromXML(@SALE) b ON a.ID_PERSONAL = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.PROCESS_TYPE = N'SALE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_SALE)
            END;

            IF @RIVAL_PERS IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_RIVAL_PERS
                FROM Client.CompanyProcess a
                INNER JOIN Common.TableGUIDFromXML(@RIVAL_PERS) b ON a.ID_PERSONAL = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.PROCESS_TYPE = N'RIVAL' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_RIVAL_PERS)
            END;

            IF @MANAGER IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_MANAGER
                FROM Client.CompanyProcess a
                INNER JOIN Common.TableGUIDFromXML(@MANAGER) b ON a.ID_PERSONAL = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.PROCESS_TYPE = N'MANAGER' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_MANAGER)
            END;

            IF @AGENT IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_AGENT
                FROM Client.CompanyProcess a
                INNER JOIN Common.TableGUIDFromXML(@AGENT) b ON a.ID_PERSONAL = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.PROCESS_TYPE = N'PHONE' AND a.EDATE IS NULL AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_AGENT)
            END;

            IF @RIVAL IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_RIVAL
                FROM Client.CompanyRival a
                INNER JOIN Common.TableGUIDFromXML(@RIVAL) b ON a.ID_RIVAL = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.STATUS = 1 AND ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_RIVAL)
            END;

            IF @RIVALV IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID_COMPANY, @FilterType_RIVALV
                FROM Client.CompanyRival a
                INNER JOIN Common.TableGUIDFromXML(@RIVALV) b ON a.ID_VENDOR = b.ID
                INNER JOIN Client.Company c ON c.ID = a.ID_COMPANY
                WHERE a.STATUS = 1 AND ACTIVE = 1 AND (c.STATUS = 1 OR c.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_RIVALV)
            END;

            IF @CHARACTER IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT a.ID, @FilterType_CHARACTER
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@CHARACTER) b ON a.ID_CHARACTER = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_CHARACTER)
            END;

            IF @REMOTE IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_REMOTE
                FROM Client.Company a
                INNER JOIN Common.TableGUIDFromXML(@REMOTE) b ON a.ID_REMOTE = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_REMOTE)
            END;

            IF @PROJECT IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT a.ID, @FilterType_PROJECT
                FROM Client.Company a
                INNER JOIN Client.CompanyProject c ON a.ID = c.ID_COMPANY
                INNER JOIN Common.TableGUIDFromXML(@PROJECT) b ON c.ID_PROJECT = b.ID
                WHERE (a.STATUS = 1 OR a.STATUS = 3 AND @DELETED = 1);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_PROJECT)
            END;

            IF @CALL_BEGIN	IS NOT NULL OR @CALL_END IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID_COMPANY, @FilterType_CALL
                FROM Client.CallDate
                WHERE (DATE >= @CALL_BEGIN OR @CALL_BEGIN IS NULL)
                    AND (DATE <= @CALL_END OR @CALL_END IS NULL);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_CALL)
            END;

            IF @BLACK = 1 BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID, @FilterType_BLACK
                FROM Client.Company
                WHERE STATUS = 1 AND BLACK_LIST = 1;

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_BLACK)
            END;

            IF @BLACK_NOTE IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID, @FilterType_BLACK_NOTE
                FROM Client.Company
                WHERE STATUS = 1 AND BLACK_NOTE LIKE @BLACK_NOTE;

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_BLACK_NOTE)
            END;

            IF @DEPO = 1 BEGIN
                INSERT INTO @IdByFilterType
                SELECT DISTINCT Company_Id, @FilterType_DEPO
                FROM Client.CompanyDepo
                --ToDo убрать хардкод
                WHERE STATUS = 1 AND Status_Id IN (1, 2, 3);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_DEPO)
            END;

            IF @DEPO_NUM IS NOT NULL BEGIN
                INSERT INTO @IdByFilterType
                SELECT Company_Id, @FilterType_DEPO_NUM
                FROM Client.CompanyDepo
                WHERE STATUS = 1
                    AND Status_Id IN (1, 2, 3)
                    AND Number IN
                    (
                        SELECT ITEM
                        FROM Common.IntTableFromList(@DEPO_NUM, ',')
                    );

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_DEPO_NUM)
            END;

            IF @HISTORY = 1 BEGIN
                INSERT INTO @IdByFilterType
                SELECT ID, @FilterType_HISTORY
                FROM Client.CompanyCallView WITH(NOEXPAND);

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_HISTORY)
            END;

            IF @SELECT = 1 BEGIN
                INSERT INTO @company([Id])
                SELECT ID_COMPANY
                FROM Client.CompanySelection
                WHERE USR_NAME = ORIGINAL_LOGIN();

                INSERT INTO @UsedFilterTypes
                VALUES(@FilterType_SELECTION)
            END

            IF EXISTS (SELECT * FROM @UsedFilterTypes)
                INSERT @company ([Id])
                SELECT
                    [Id] = D.[Id]
                FROM
                (
                    SELECT
                        [Id] = D.[Id]
                    FROM    
                    (
                        SELECT DISTINCT [Id] = CD.[Id]
                        FROM @IdByFilterType CD
                    ) D
                    CROSS JOIN @UsedFilterTypes C
                    LEFT JOIN @IdByFilterType CD ON CD.[Type] = C.[Type] AND CD.[Id] = D.[Id]
                    GROUP BY D.[Id]
                    HAVING Count(*) = Count(CD.[Id])
                ) D
                INNER JOIN @rlist P ON P.[ID] = D.[Id]
            ELSE
                INSERT @company ([Id])
                SELECT TOP (500) Id
                FROM @rlist;
        END;

        SELECT
            a.ID, b.NUMBER, b.STATUS,
            CONVERT(BIT, CASE WHEN c.ID IS NOT NULL THEN 1 ELSE 0 END) AS WRITE,
            t.ADDRESS AS SHORT, b.NAME, WORK_DATE, BLACK_LIST,

            ID_AVAILABILITY,
            AVA_COLOR,
            ID_POTENTIAL,
            ID_WORK_STATE,
            ID_PAY_CAT,
            ID_NEXT_MON,
            ID_CHARACTER,
            --ID_SENDER,
            INDX = SenderIndex,

            h.SHORT AS PHONE_SHORT,
            j.SHORT AS SALE_SHORT,
            n.SHORT AS MAN_SHORT,
            s.SHORT AS RIVAL_SHORT,

            /*
            d.NAME AS AVA_NAME,
            CONVERT(BIT, CASE
                WHEN d.COLOR IS NULL THEN 0
                ELSE 1
            END) AS AVA,
            d.COLOR AS AVA_COLOR,
            e.NAME AS POT_NAME,
            f.NAME AS WS_NAME,
            g.NAME AS PC_NAME,
            h.SHORT AS PHONE_SHORT,
            j.SHORT AS SALE_SHORT,
            n.SHORT AS MAN_SHORT,
            s.SHORT AS RIVAL_SHORT,
            l.NAME AS MON_NAME,
            l.DATE AS MON_DATE,
            q.NAME AS CHAR_NAME,
            w.INDX,
            */
            PAPER_CARD,
            DEPO = Cast(IsNull(DP.IsDepo, 0) AS Bit),
            CONTROL = IsNull(m.CONTROL, 0),
            ARCHIVE = IsNull(p.ARCHIVE, 0),
            HISTORY = IsNull(r.HISTORY, 0),
            WARNING = IsNull(war.WARNING, 0),
            u.DATE AS CALL_DATE,
            DEPO_NUM = DP.Number,
            t.PROJECTS AS PRJ_NAME,
            [EMAIL] = t.EMAILS
        FROM @company a
        INNER JOIN Client.CompanyActiveView b WITH(NOEXPAND) ON a.ID = b.ID
        LEFT JOIN Client.CompanyIndex t ON t.ID_COMPANY = a.ID
        LEFT JOIN @wlist c ON c.ID = a.ID
        LEFT JOIN Client.CallDate u ON u.ID_COMPANY = a.ID
        LEFT JOIN Client.CompanyProcessPhoneView h WITH(NOEXPAND) ON h.ID = b.ID
        LEFT JOIN Client.CompanyProcessSaleView j WITH(NOEXPAND) ON j.ID = b.ID
        LEFT JOIN Client.CompanyProcessManagerView n WITH(NOEXPAND) ON n.ID = b.ID
        LEFT JOIN Client.CompanyProcessRivalView s WITH(NOEXPAND) ON s.ID = b.ID
        -- ToDo сделать лукап-поля
        /*
        LEFT JOIN Client.Availability d ON d.ID = b.ID_AVAILABILITY
        LEFT JOIN Client.Potential e ON e.ID = b.ID_POTENTIAL
        LEFT JOIN Client.WorkState f ON f.ID = b.ID_WORK_STATE
        LEFT JOIN Client.PayCategory g ON g.ID = b.ID_PAY_CAT
        LEFT JOIN Client.CompanyProcessPhoneView h WITH(NOEXPAND) ON h.ID = b.ID
        LEFT JOIN Client.CompanyProcessSaleView j WITH(NOEXPAND) ON j.ID = b.ID
        LEFT JOIN Common.Month l ON l.ID = b.ID_NEXT_MON
        LEFT JOIN Client.CompanyProcessManagerView n WITH(NOEXPAND) ON n.ID = b.ID
        LEFT JOIN Client.Character q ON q.ID = b.ID_CHARACTER
        LEFT JOIN Client.CompanyProcessRivalView s WITH(NOEXPAND) ON s.ID = b.ID
        LEFT JOIN Client.Sender w ON w.ID = b.ID_SENDER
        */
        OUTER APPLY
        (
            SELECT TOP (1) CONTROL = Cast(1 As Bit)
            FROM Client.CompanyControlView AS m WITH(NOEXPAND)
            WHERE m.ID_COMPANY = a.ID
        ) AS m
        OUTER APPLY
        (
            SELECT TOP (1) ARCHIVE = Cast(1 As Bit)
            FROM Client.CompanyArchiveView AS p WITH(NOEXPAND)
            WHERE p.ID_COMPANY = a.ID
        ) AS p
        OUTER APPLY
        (
            SELECT TOP (1) HISTORY = Cast(1 As Bit)
            FROM Client.CompanyCallView AS r WITH(NOEXPAND)
            WHERE r.ID = a.ID
        ) AS r
        OUTER APPLY
        (
            SELECT TOP (1) WARNING = Cast(1 As Bit)
            FROM Client.CompanyWarningView AS war WITH(NOEXPAND)
            WHERE war.ID_COMPANY = a.ID
        ) AS war
        OUTER APPLY
        (
            SELECT TOP (1)
                DP.[Number],
                IsDepo = Cast(1 As Bit)
            FROM Client.CompanyDepo DP
            WHERE DP.Company_Id = a.ID
                AND DP.Status = 1
                -- ToDo убрать хардкод
                AND DP.Status_Id IN (3)
            ORDER BY DP.DateFrom DESC
        ) AS DP
        ORDER BY b.NAME, b.NUMBER
        OPTION(RECOMPILE)


        SELECT @RC = @@ROWCOUNT

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [Client].[COMPANY_SELECT2] TO rl_company_r;
GO