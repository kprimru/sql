USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_BANK_PRINT_SELECT]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_BANK_PRINT_SELECT]  AS SELECT 1')
GO
ALTER PROCEDURE [dbo].[SYSTEM_BANK_PRINT_SELECT]
    @DistrType_Id   SmallInt = NULL,
    @Hosts_IDs      VarChar(Max) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE @Hosts Table (Id SmallInt Primary Key Clustered);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
        IF @DistrType_Id IS NULL
		    SELECT
			    a.SystemID, SystemShortName, SystemBaseName, SystemFullName, SystemNumber,
			    (
				    SELECT COUNT(*)
				    FROM
					    dbo.SystemBankTable z
					    INNER JOIN dbo.InfoBankTable y ON y.InfoBankID = z.InfoBankID
				    WHERE a.SystemID = z.SystemID AND y.InfoBankActive = 1
			    ) AS SYS_CNT,
			    c.InfoBankID, InfoBankShortName, InfoBankFullName, InfoBankName
		    FROM
			    dbo.SystemTable a
			    INNER JOIN dbo.SystemBankTable b ON a.SystemID = b.SystemID
			    INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.InfoBankID
		    WHERE SystemActive = 1 AND InfoBankActive = 1
		    ORDER BY SystemOrder, SystemID, InfoBankOrder, InfoBankID
		ELSE BEGIN
		    INSERT INTO @Hosts
		    SELECT Item
		    FROM SQL.Split(@Hosts_IDs, ',');

		    SELECT
			    a.SystemID, SystemShortName, SystemBaseName, SystemFullName, SystemNumber,
			    (
				    SELECT COUNT(*)
				    FROM dbo.SystemsBanks z
					INNER JOIN dbo.InfoBankTable y ON y.InfoBankID = z.InfoBank_Id
				    WHERE a.SystemID = z.System_Id AND y.InfoBankActive = 1
				        AND z.DistrType_Id = @DistrType_Id
			    ) AS SYS_CNT,
			    c.InfoBankID, InfoBankShortName, InfoBankFullName, InfoBankName
		    FROM dbo.SystemTable a
			INNER JOIN dbo.SystemsBanks b ON a.SystemID = b.System_Id AND b.DistrType_Id = @DistrType_Id
			INNER JOIN dbo.InfoBankTable c ON c.InfoBankID = b.InfoBank_Id
			INNER JOIN @Hosts AS h ON a.HostID = h.Id
		    WHERE SystemActive = 1 AND InfoBankActive = 1
		    ORDER BY SystemOrder, SystemID, InfoBankOrder, InfoBankID
		END;

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
	END TRY
	BEGIN CATCH
		SET @DebugError = Error_Message();

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

		EXEC [Maintenance].[ReRaise Error];
	END CATCH
END
GO
GRANT EXECUTE ON [dbo].[SYSTEM_BANK_PRINT_SELECT] TO rl_system_r;
GO
