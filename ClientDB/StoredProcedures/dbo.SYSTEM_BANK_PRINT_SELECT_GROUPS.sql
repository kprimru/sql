USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANK_PRINT_SELECT_GROUPS]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @Host_Id        SmallInt,
        @DistrType_Id   SmallInt;

    DECLARE @DistrsTypes Table
    (
        Id      SmallInt,
        Name    VarChar(100),
        Data    VarChar(Max),
        Primary Key Clustered([Id])
    );

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        SET @Host_Id = (SELECT TOP (1) [HostId] FROM [dbo].[Hosts] WHERE [HostReg] = 'LAW');
        SET @DistrType_Id = (SELECT TOP (1) [DistrTypeId] FROM [dbo].[DistrTypeTable] WHERE [DistrTypeCode] = 'LOCAL');

        INSERT INTO @DistrsTypes
        SELECT D.DistrTypeID, D.DistrTypeName, Cast(I.[Data] AS VarChar(Max))
        FROM dbo.DistrTypeTable AS D
        CROSS APPLY
        (
            SELECT
                [Data] =
                    (
                        SELECT
                            S.[SystemBaseName] + ':' + I.[InfoBankName] + Char(10)
                        FROM dbo.SystemsBanks           AS B
                        INNER JOIN dbo.SystemTable      AS S ON S.SystemID = B.System_Id
                        INNER JOIN dbo.InfoBankTable    AS I ON I.InfoBankID = B.InfoBank_Id
                        WHERE B.Required = 1
                            AND B.DistrType_Id = D.DistrTypeID
                            AND S.[HostId] = @Host_Id
                        ORDER BY S.SystemID, I.InfoBankID FOR XML PATH('')
                    )
        ) AS I;

        SELECT
            [SortIndex]     = 1,
            [DistrType_Id]  = T.[Id],
            [Host_Id]       = Cast(@Host_Id AS VarChar(Max)),
            [GroupName]     = N.[GroupName]
        FROM
        (
		    SELECT DISTINCT DATA
		    FROM @DistrsTypes
		    WHERE DATA IS NOT NULL
		) AS D
		CROSS APPLY
		(
		    SELECT TOP (1) T.[Id]
		    FROM @DistrsTypes AS T
		    WHERE T.[Data] = D.[Data]
		    ORDER BY T.[Id]
		) AS T
		CROSS APPLY
		(
		    SELECT
		        [GroupName] = Reverse(Stuff(Reverse(
		            (
		                SELECT
		                    Replace(N.[Name], '/', '-') + ', '
		                FROM @DistrsTypes AS N
		                WHERE N.[Data] = D.[Data]
		                ORDER BY N.Id FOR XML PATH('')
		            )
		        ), 1, 2, ''))
		) AS N

		UNION ALL

		SELECT
		    [SortIndex]     = 2,
		    [DistrType_Id]  = @DistrType_Id,
            [Host_Id]       =   Reverse(Stuff(Reverse(
                                    (
                                        SELECT Convert(VarChar(10), HostId) + ','
                                        FROM dbo.Hosts
                                        WHERE HostId != @Host_Id
                                        FOR XML PATH('')
                                    )
                                ), 1, 1, '')),
            [GroupName]     = 'Дополнительные системы'

		ORDER BY [SortIndex] DESC, [DistrType_Id] DESC;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANK_PRINT_SELECT_GROUPS] TO rl_system_r;
GO
