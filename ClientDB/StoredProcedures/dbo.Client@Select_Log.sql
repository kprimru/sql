USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[Client@Select?Log]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[Client@Select?Log]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[Client@Select?Log]
    @Client_Id      Int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Details Table
    (
        [Row:Index]         Int,
        [Checksum]          Int,
        [UpdateDate]        DateTime,
        [UPD_USER]          VarChar(128),
        [ClientFullName]    VarChar(512),
        [ClientOfficial]    VarChar(512),
        [ClientINN]         VarChar(50),
        [ServiceName]       VarChar(100),
        [ClientActivity]    VarChar(250),
        [ClientDayBegin]    VarChar(20),
        [ClientDayEnd]      VarChar(20),
        [DayName]           VarChar(20),
        [ServiceStart]      VarChar(20),
        [ServiceTime]       VarChar(20),
        [PayTypeNmae]       VarChar(50),
        [ClientMainBook]    Int,
        [ClientNewspaper]   Int,
        [ServiceStatusName] VarChar(50),
        [ClientNote]        VarChar(Max),
        [ServiceTypeName]   VarChar(50),
        [RangeValue]        Float,
        [OriClient]         Bit,
        [ClientEmail]       VarChar(250),
        [ClientPlace]       VarChar(Max),
        [PurchaseTypeName]  VarChar(50),
        [DinnerBegin]       VarChar(20),
        [DinnerEnd]         VarChar(20),
        [ClientVisitCount]  VarChar(20),
        [IsLarge]           Bit,
        [IsDebtor]          Bit,
        [ClientTypeName]    VarChar(20),
        [ClientKindName]    VarChar(50),
        [Names]             VarChar(Max),
        [Addresses]         VarChar(Max),
        [Personals]         VarChar(Max),
        PRIMARY KEY CLUSTERED([Row:index])
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        INSERT INTO @Details
        SELECT
            [Row:Index]         = Row_Number() OVER(ORDER BY C.[ClientLast]),
            [Checksum]          = NULL,
            [UpdateDate]        = C.[ClientLast],
            [UPD_USER]          = C.[UPD_USER],
            [ClientFullName]    = C.[ClientFullName],
            [ClientOfficial]    = C.[ClientOfficial],
            [ClientINN]         = C.[ClientINN],
            [ServiceName]       = S.[ServiceName],
            [ClientActivity]    = C.[ClientActivity],
            [ClientDayBegin]    = C.[ClientDayBegin],
            [ClientDayEnd]      = C.[ClientDayEnd],
            [DayName]           = D.[DayName],
            [ServiceStart]      = Left(Convert(VarChar(20), C.[ServiceStart], 108), 5),
            [ServiceTime]       = C.[ServiceTime],
            [PayTypeNmae]       = P.[PayTypeName],
            [ClientMainBook]    = C.[ClientMainBook],
            [ClientNewspaper]   = C.[ClientNewspaper],
            [ServiceStatusName] = SS.[ServiceStatusName],
            [ClientNote]        = C.[ClientNote],
            [ServiceTypeName]   = ST.[ServiceTypeName],
            [RangeValue]        = R.[RangeValue],
            [OriClient]         = C.[OriClient],
            [ClientEmail]       = C.[ClientEmail],
            [ClientPlace]       = C.[ClientPlace],
            [PurchaseTypeName]  = PT.[PT_NAME],
            [DinnerBegin]       = C.[DinnerBegin],
            [DinnerEnd]         = C.[DinnerEnd],
            [ClientVisitCount]  = CV.[NAME],
            [IsLarge]           = C.[IsLarge],
            [IsDebtor]          = C.[IsDebtor],
            [ClientTypeName]    = CT.[ClientTypeName],
            [ClientKindName]    = CK.[Name],
            [Names]             = N.[NAMES],
            [Addresses]         = A.[ADDRESSES],
            [Personals]         = PR.[PERSONALS]
        FROM [dbo].[ClientTable]                AS C
        LEFT JOIN [dbo].[ServiceTable]          AS S    ON S.[ServiceID] = C.[ClientServiceID]
        LEFT JOIN [dbo].[DayTable]              AS D    ON D.[DayID] = C.[DayID]
        LEFT JOIN [dbo].[PayTypeTable]          AS P    ON P.[PayTypeID] = C.[PayTypeID]
        LEFT JOIN [dbo].[ServiceStatusTable]    AS SS   ON SS.[ServiceStatusID] = C.[StatusID]
        LEFT JOIN [dbo].[ServiceTypeTable]      AS ST   ON ST.[ServiceTypeID] = C.[ServiceTypeID]
        LEFT JOIN [dbo].[RangeTable]            AS R    ON R.[RangeID] = C.[RangeID]
        LEFT JOIN [Purchase].[PurchaseType]     AS PT   ON PT.[PT_ID] = C.[PurchaseTypeID]
        LEFT JOIN [dbo].[ClientVisitCount]      AS CV   ON CV.[ID] = C.[ClientVisitCountID]
        LEFT JOIN [dbo].[ClientTypeTable]       AS CT   ON CT.[ClientTypeID] = C.[ClientTypeID]
        LEFT JOIN [dbo].[ClientKind]            AS CK   ON CK.[Id] = C.[ClientKind_Id]
        OUTER APPLY
        (
            SELECT
                [NAMES] =
                    (
                        SELECT N.[NAME] + CHAR(10)
                        FROM [dbo].[ClientNames] AS N
                        WHERE N.[ID_CLIENT] = C.[ClientID]
                        ORDER BY N.[NAME]
                        FOR XML PATH('')
                    )
        ) AS N
        OUTER APPLY
        (
            SELECT
                [ADDRESSES] =
                    (
                        SELECT A.[CA_STR_PRNT] + CHAR(10)
                        FROM [dbo].[ClientAddressFullView] AS A
                        WHERE A.[CA_ID_CLIENT] = C.[ClientID]
                        ORDER BY A.[CA_STR_PRNT]
                        FOR XML PATH('')
                    )
        ) AS A
        OUTER APPLY
        (
            SELECT
                [PERSONALS] =
                    (
                        SELECT
                            CASE ISNULL(CP_SURNAME, '')
                                WHEN '' THEN ''
                                ELSE CP_SURNAME + ' '
                            END +
                            CASE ISNULL(CP_NAME, '')
                                WHEN '' THEN ''
                                ELSE CP_NAME + ' '
                            END +
                            ISNULL(CP_PATRON, '') +
                            ' ' + CP_POS + ' ' + CP_PHONE + ' ' + CP_EMAIL +
                            CHAR(10)
                        FROM [dbo].[ClientPersonal]             AS PR
                        LEFT JOIN [dbo].[ClientPersonalType]    AS T ON T.[CPT_ID] = PR.[CP_ID_TYPE]
                        WHERE PR.[CP_ID_CLIENT] = C.[ClientID]
                        ORDER BY T.[CPT_REQUIRED] DESC, T.[CPT_ORDER], [CP_SURNAME], [CP_NAME]
                        FOR XML PATH('')
                    )
        ) AS PR
        WHERE [ID_MASTER] = @Client_Id
        ORDER BY C.[ClientLast] DESC;

        UPDATE @Details SET
            [Checksum] = Binary_Checksum(
                            [ClientFullName],
                            [ClientOfficial],
                            [ClientINN],
                            [ServiceName],
                            [ClientActivity],
                            [ClientDayBegin],
                            [ClientDayEnd],
                            [DayName],
                            [ServiceStart],
                            [ServiceTime],
                            [PayTypeNmae],
                            [ClientMainBook],
                            [ClientNewspaper],
                            [ServiceStatusName],
                            [ClientNote],
                            [ServiceTypeName],
                            [RangeValue],
                            [OriClient],
                            [ClientEmail],
                            [ClientPlace],
                            [PurchaseTypeName],
                            [DinnerBegin],
                            [DinnerEnd],
                            [ClientVisitCount],
                            [IsLarge],
                            [IsDebtor],
                            [ClientTypeName],
                            [ClientKindName],
                            [Names],
                            [Addresses],
                            [Personals]
                            );

        WITH CTE AS
        (
            SELECT
                [Index] = 1,
                D.[Row:Index],
                D.[ClientFullName],
                D.[ClientOfficial],
                D.[ClientINN],
                D.[ServiceName],
                D.[ClientActivity],
                D.[ClientDayBegin],
                D.[ClientDayEnd],
                D.[DayName],
                D.[ServiceStart],
                D.[ServiceTime],
                D.[PayTypeNmae],
                D.[ClientMainBook],
                D.[ClientNewspaper],
                D.[ServiceStatusName],
                D.[ClientNote],
                D.[ServiceTypeName],
                D.[RangeValue],
                D.[OriClient],
                D.[ClientEmail],
                D.[ClientPlace],
                D.[PurchaseTypeName],
                D.[DinnerBegin],
                D.[DinnerEnd],
                D.[ClientVisitCount],
                D.[IsLarge],
                D.[IsDebtor],
                D.[ClientTypeName],
                D.[ClientKindName],
                D.[Names],
                D.[Addresses],
                D.[Personals],
                D.[Checksum],
                D.[UpdateDate],
                D.[UPD_USER]
            FROM @Details AS D
            WHERE D.[Row:Index] = 1
            ---
            UNION ALL
            ---
            SELECT
                CASE WHEN D.[Checksum] = CTE.[Checksum] THEN CTE.[Index] + 1 ELSE 1 END,
                D.[Row:Index],
                D.[ClientFullName],
                D.[ClientOfficial],
                D.[ClientINN],
                D.[ServiceName],
                D.[ClientActivity],
                D.[ClientDayBegin],
                D.[ClientDayEnd],
                D.[DayName],
                D.[ServiceStart],
                D.[ServiceTime],
                D.[PayTypeNmae],
                D.[ClientMainBook],
                D.[ClientNewspaper],
                D.[ServiceStatusName],
                D.[ClientNote],
                D.[ServiceTypeName],
                D.[RangeValue],
                D.[OriClient],
                D.[ClientEmail],
                D.[ClientPlace],
                D.[PurchaseTypeName],
                D.[DinnerBegin],
                D.[DinnerEnd],
                D.[ClientVisitCount],
                D.[IsLarge],
                D.[IsDebtor],
                D.[ClientTypeName],
                D.[ClientKindName],
                D.[Names],
                D.[Addresses],
                D.[Personals],
                D.[Checksum],
                D.[UpdateDate],
                D.[UPD_USER]
            FROM @Details AS D
            INNER JOIN CTE ON D.[Row:Index] = CTE.[Row:Index] + 1
        )
        SELECT
            [Row:Index],
            [ClientFullName],
            [ClientOfficial],
            [ClientINN],
            [ServiceName],
            [ClientActivity],
            [ClientDayBegin],
            [ClientDayEnd],
            [DayName],
            [ServiceStart],
            [ServiceTime],
            [PayTypeNmae],
            [ClientMainBook],
            [ClientNewspaper],
            [ServiceStatusName],
            [ClientNote],
            [ServiceTypeName],
            [RangeValue],
            [OriClient],
            [ClientEmail],
            [ClientPlace],
            [PurchaseTypeName],
            [DinnerBegin],
            [DinnerEnd],
            [ClientVisitCount],
            [IsLarge],
            [IsDebtor],
            [ClientTypeName],
            [ClientKindName],
            [Names],
            [Addresses],
            [Personals],
            [UpdateDate],
            [UPD_USER]
        FROM CTE
        WHERE [Index] = 1
        ORDER BY [UpdateDate] DESC
        OPTION (MAXRECURSION 0);

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH

END
GO
GRANT EXECUTE ON [dbo].[Client@Select?Log] TO rl_client_card;
GO
