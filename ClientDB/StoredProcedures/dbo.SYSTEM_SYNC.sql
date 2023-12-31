USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SYSTEM_SYNC]
	@System_Id      SmallInt
WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @Short      VarChar(100),
        @Reg        VarChar(100),
        @Full       VarCHar(256),
        @Ord        SmallInt,
        @Host_Id    SmallInt,
        @Date       SmallDateTime;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY
        SET @Date = dbo.DateOf(GetDate());

        BEGIN TRAN;

        SELECT
            @Short      = S.SystemShortName,
            @Reg        = S.SystemBaseName,
            @Full       = S.SystemFullName,
            @Ord        = S.SYstemOrder,
            @Host_Id    = S.HostId
        FROM dbo.SystemTable AS S
        WHERE SystemID = @System_Id;

        INSERT INTO [PC275-SQL\GAMMA].[SaleDB].[System].[Systems](NAME, SHORT, REG, HOST, ORD)
        SELECT S.SystemFullName, S.SystemShortName, S.SystemBaseName, H.HostReg, S.SystemOrder
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        WHERE SystemID = @System_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [PC275-SQL\GAMMA].[SaleDB].[System].[Systems] AS Z
                WHERE Z.[REG] = S.SystemBaseName
            );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\GAMMA].[SaleDB].[System].[Systems]')

        INSERT INTO [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[Host](SHORT, REG, ORD)
        SELECT HostShort, HostReg, HostOrder
        FROM dbo.Hosts AS D
        WHERE D.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[Host] AS H
                WHERE D.HostReg = H.REG
            );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[Host]')

        INSERT INTO [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[System](SHORT, REG, ID_HOST, ORD)
        SELECT S.SystemShortName, S.SystemBaseName, DC.ID, S.SYstemOrder
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[Host] AS DC ON DC.REG = H.HostReg
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[System] AS Z
                    WHERE Z.REG = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\GAMMA].[DocumentClaim].[Distr].[System]')

        IF NOT EXISTS (SELECT TOP (1) * FROM [PC275-SQL\GAMMA].[FirstInstall].[Distr].[SystemActive] WHERE SYS_REG = @Reg) BEGIN
            EXEC [PC275-SQL\GAMMA].[FirstInstall].[Distr].[SYSTEM_INSERT]
                @SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

            PRINT ('��������� � [PC275-SQL\GAMMA].[FirstInstall].[Distr].[SystemDetail]')
        END;

        IF NOT EXISTS (SELECT TOP (1) * FROM [PC275-SQL\GAMMA].[FirstInstallNah].[Distr].[SystemActive] WHERE SYS_REG = @Reg) BEGIN
            EXEC [PC275-SQL\GAMMA].[FirstInstallNah].[Distr].[SYSTEM_INSERT]
                @SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

            PRINT ('��������� � [PC275-SQL\GAMMA].[FirstInstallNah].[Distr].[SystemDetail]')
        END;

        INSERT INTO [PC275-SQL\DELTA].[DBF].[dbo].[HostTable](HST_NAME, HST_REG_NAME, HST_REG_FULL, HST_ACTIVE)
        SELECT HostShort, HostReg, HostReg, 1
        FROM dbo.Hosts AS C
        WHERE C.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [PC275-SQL\DELTA].[DBF].[dbo].[HostTable] AS D
                WHERE D.HST_REG_FULL = C.HostReg
            );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\DELTA].[DBF].[dbo].[HostTable]')

        INSERT INTO [PC275-SQL\DELTA].[DBF_NAH].[dbo].[HostTable](HST_NAME, HST_REG_NAME, HST_REG_FULL, HST_ACTIVE)
        SELECT HostShort, HostReg, HostReg, 1
        FROM dbo.Hosts AS C
        WHERE C.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [PC275-SQL\DELTA].[DBF_NAH].[dbo].[HostTable] AS D
                WHERE D.HST_REG_FULL = C.HostReg
            );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\DELTA].[DBF_NAH].[dbo].[HostTable]')

        INSERT INTO [PC275-SQL\DELTA].[DBF].[dbo].[SystemTable](SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME, SYS_ID_HOST, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE)
        SELECT '', S.SystemFullName, S.SystemShortName, DH.HST_ID, S.SystemBaseName, 1, S.SystemOrder, 0, 1, ''
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [PC275-SQL\DELTA].[DBF].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
        WHERE S.SystemId = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [PC275-SQL\DELTA].[DBF].[dbo].[SystemTable] AS Z
                    WHERE Z.SYS_REG_NAME = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\DELTA].[DBF].[dbo].[SystemTable]')

        INSERT INTO [PC275-SQL\DELTA].[DBF_NAH].[dbo].[SystemTable](SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME, SYS_ID_HOST, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE)
        SELECT '', S.SystemFullName, S.SystemShortName, DH.HST_ID, S.SystemBaseName, 1, S.SystemOrder, 0, 1, ''
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [PC275-SQL\DELTA].[DBF_NAH].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
        WHERE S.SystemId = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [PC275-SQL\DELTA].[DBF_NAH].[dbo].[SystemTable] AS Z
                    WHERE Z.SYS_REG_NAME = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\DELTA].[DBF_NAH].[dbo].[SystemTable]')

        INSERT INTO [PC275-SQL\GAMMA].[BuhDB].[dbo].[SystemTable](SystemName, SystemPrefix, SystemGroupID, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, IsExpired)
        SELECT S.SystemFullName, '', 1, '', 0, 1, 1, 1, '', SystemBaseName, 0, 0
        FROM dbo.SystemTable AS S
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [PC275-SQL\GAMMA].[BuhDB].[dbo].[SystemTable] AS Z
                    WHERE Z.SystemReg = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\GAMMA].[BuhDB].[dbo].[SystemTable]')

        INSERT INTO [PC275-SQL\GAMMA].[BuhNahDB].[dbo].[SystemTable](SystemName, SystemPrefix, SystemGroupID, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, IsExpired)
        SELECT S.SystemFullName, '', 1, '', 0, 1, 1, 1, '', SystemBaseName, 0, 0
        FROM dbo.SystemTable AS S
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [PC275-SQL\GAMMA].[BuhNahDB].[dbo].[SystemTable] AS Z
                    WHERE Z.SystemReg = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('��������� � [PC275-SQL\GAMMA].[BuhNahDB].[dbo].[SystemTable]')

        IF @@TRANCOUNT > 0
            COMMIT TRAN;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
