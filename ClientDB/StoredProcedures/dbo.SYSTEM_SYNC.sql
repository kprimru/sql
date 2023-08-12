USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[SYSTEM_SYNC]', 'P ') IS NULL EXEC('CREATE PROCEDURE [dbo].[SYSTEM_SYNC]  AS SELECT 1')
GO
CREATE OR ALTER PROCEDURE [dbo].[SYSTEM_SYNC]
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

        INSERT INTO [SaleDB].[System].[Systems](NAME, SHORT, REG, HOST, ORD)
        SELECT S.SystemFullName, S.SystemShortName, S.SystemBaseName, H.HostReg, S.SystemOrder
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        WHERE SystemID = @System_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [SaleDB].[System].[Systems] AS Z
                WHERE Z.[REG] = S.SystemBaseName
            );

        IF @@RowCount > 0
            PRINT ('Добавлено в [SaleDB].[System].[Systems]')
		ELSE BEGIN
			UPDATE SS SET
				[NAME] = S.[SystemFullName],
				[SHORT] = S.[SystemShortName],
				[HOST] = H.[HostReg],
				[ORD] = S.[SystemOrder]
			FROM [SaleDB].[System].[Systems] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.[REG] = S.SystemBaseName
			INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
			WHERE SystemID = @System_Id;

			PRINT ('Обновлено в [SaleDB].[System].[Systems]')
		END;

        INSERT INTO [DocumentClaim].[Distr].[Host](SHORT, REG, ORD)
        SELECT HostShort, HostReg, HostOrder
        FROM dbo.Hosts AS D
        WHERE D.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [DocumentClaim].[Distr].[Host] AS H
                WHERE D.HostReg = H.REG
            );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DocumentClaim].[Distr].[Host]')
		ELSE BEGIN
			UPDATE H SET
				[SHORT] = D.[HostShort],
				[REG] = D.[HostReg],
				[ORD] = D.[HostOrder]
			FROM [DocumentClaim].[Distr].[Host] AS H
			INNER JOIN dbo.Hosts AS D ON D.HostReg = H.REG
			WHERE D.HostID = @Host_Id;

			PRINT ('Обновлено в [DocumentClaim].[Distr].[Host]')
		END;

        INSERT INTO [DocumentClaim].[Distr].[System](SHORT, REG, ID_HOST, ORD)
        SELECT S.SystemShortName, S.SystemBaseName, DC.ID, S.SYstemOrder
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [DocumentClaim].[Distr].[Host] AS DC ON DC.REG = H.HostReg
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [DocumentClaim].[Distr].[System] AS Z
                    WHERE Z.REG = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DocumentClaim].[Distr].[System]')
		ELSE BEGIN
			UPDATE SS SET
				[SHORT] = S.[SystemShortName],
				[REG] = S.[SystemBaseName],
				[ID_HOST] = DC.[ID],
				[ORD] = S.[SystemOrder]
			FROM [DocumentClaim].[Distr].[System] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.REG = S.SystemBaseName
			INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
			INNER JOIN [DocumentClaim].[Distr].[Host] AS DC ON DC.REG = H.HostReg
			WHERE S.SystemID = @System_Id;

			PRINT ('Обновлено в [DocumentClaim].[Distr].[System]');
		END;

        IF NOT EXISTS (SELECT TOP (1) * FROM [FirstInstall].[Distr].[SystemActive] WHERE SYS_REG = @Reg) BEGIN
            EXEC [FirstInstall].[Distr].[SYSTEM_INSERT]
                @SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

            PRINT ('Добавлено в [FirstInstall].[Distr].[SystemDetail]')
        END ELSE BEGIN
			DECLARE @Sys_Id_FI  UniqueIdentifier = (SELECT SYS_ID FROM [FirstInstall].[Distr].[SystemActive] WHERE SYS_REG = @Reg);

			EXEC [FirstInstall].[Distr].[SYSTEM_UPDATE]
				@SYS_ID			= @Sys_Id_FI,
				@SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

			PRINT ('Обновлено в [FirstInstall].[Distr].[SystemDetail]')
		END;

        IF NOT EXISTS (SELECT TOP (1) * FROM [FirstInstallNah].[Distr].[SystemActive] WHERE SYS_REG = @Reg) BEGIN
            EXEC [FirstInstallNah].[Distr].[SYSTEM_INSERT]
                @SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

            PRINT ('Добавлено в [FirstInstallNah].[Distr].[SystemDetail]')
        END ELSE BEGIN
			DECLARE @Sys_Id_FIN  UniqueIdentifier = (SELECT SYS_ID FROM [FirstInstallNah].[Distr].[SystemActive] WHERE SYS_REG = @Reg);

			EXEC [FirstInstallNah].[Distr].[SYSTEM_UPDATE]
				@SYS_ID			= @Sys_Id_FIN,
				@SYS_NAME       = @Full,
                @SYS_SHORT      = @Short,
                @SYS_DATE       = @Date,
                @SYS_REG        = @Reg,
                @SYS_ORDER      = @Ord;

			PRINT ('Обновлено в [FirstInstallNah].[Distr].[SystemDetail]');
		END;

        INSERT INTO [DBF].[dbo].[HostTable](HST_NAME, HST_REG_NAME, HST_REG_FULL, HST_ACTIVE)
        SELECT HostShort, HostReg, HostReg, 1
        FROM dbo.Hosts AS C
        WHERE C.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [DBF].[dbo].[HostTable] AS D
                WHERE D.HST_REG_FULL = C.HostReg
            );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF].[dbo].[HostTable]');

        INSERT INTO [DBF_NAH].[dbo].[HostTable](HST_NAME, HST_REG_NAME, HST_REG_FULL, HST_ACTIVE)
        SELECT HostShort, HostReg, HostReg, 1
        FROM dbo.Hosts AS C
        WHERE C.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [DBF_NAH].[dbo].[HostTable] AS D
                WHERE D.HST_REG_FULL = C.HostReg
            );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF_NAH].[dbo].[HostTable]');

		INSERT INTO [DBF_USS].[dbo.HostTable](HST_NAME, HST_REG_NAME, HST_REG_FULL, HST_ACTIVE)
        SELECT HostShort, HostReg, HostReg, 1
        FROM dbo.Hosts AS C
        WHERE C.HostID = @Host_Id
            AND NOT EXISTS
            (
                SELECT *
                FROM [DBF_USS].[dbo.HostTable] AS D
                WHERE D.HST_REG_FULL = C.HostReg
            );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF_USS].[dbo].[HostTable]');

        INSERT INTO [DBF].[dbo].[SystemTable](SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME, SYS_ID_HOST, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE)
        SELECT '', S.SystemFullName, S.SystemShortName, DH.HST_ID, S.SystemBaseName, 1, S.SystemOrder, 0, 1, ''
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [DBF].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
        WHERE S.SystemId = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [DBF].[dbo].[SystemTable] AS Z
                    WHERE Z.SYS_REG_NAME = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF].[dbo].[SystemTable]')
		ELSE BEGIN
			UPDATE SS SET
				SYS_NAME = S.SystemFullName,
				SYS_SHORT_NAME = S.SystemShortName,
				SYS_ID_HOST = DH.HST_ID,
				SYS_ORDER = S.SystemOrder
			FROM [DBF].[dbo].[SystemTable] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.SYS_REG_NAME = S.SystemBaseName
			INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
			INNER JOIN [DBF].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
			WHERE S.SystemId = @System_Id;

			PRINT ('Обновлено в [DBF].[dbo].[SystemTable]');
		END;

        INSERT INTO [DBF_NAH].[dbo].[SystemTable](SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME, SYS_ID_HOST, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE)
        SELECT '', S.SystemFullName, S.SystemShortName, DH.HST_ID, S.SystemBaseName, 1, S.SystemOrder, 0, 1, ''
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [DBF_NAH].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
        WHERE S.SystemId = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [DBF_NAH].[dbo].[SystemTable] AS Z
                    WHERE Z.SYS_REG_NAME = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF_NAH].[dbo].[SystemTable]')
		ELSE BEGIN
			UPDATE SS SET
				SYS_NAME = S.SystemFullName,
				SYS_SHORT_NAME = S.SystemShortName,
				SYS_ID_HOST = DH.HST_ID,
				SYS_ORDER = S.SystemOrder
			FROM [DBF_NAH].[dbo].[SystemTable] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.SYS_REG_NAME = S.SystemBaseName
			INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
			INNER JOIN [DBF_NAH].[dbo].[HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
			WHERE S.SystemId = @System_Id;

			PRINT ('Обновлено в [DBF_NAH].[dbo].[SystemTable]');
		END;

		INSERT INTO [DBF_USS].[dbo.SystemTable](SYS_PREFIX, SYS_NAME, SYS_SHORT_NAME, SYS_ID_HOST, SYS_REG_NAME, SYS_ID_SO, SYS_ORDER, SYS_REPORT, SYS_ACTIVE, SYS_1C_CODE)
        SELECT '', S.SystemFullName, S.SystemShortName, DH.HST_ID, S.SystemBaseName, 1, S.SystemOrder, 0, 1, ''
        FROM dbo.SystemTable AS S
        INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
        INNER JOIN [DBF_USS].[dbo.HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
        WHERE S.SystemId = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [DBF_USS].[dbo.SystemTable] AS Z
                    WHERE Z.SYS_REG_NAME = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [DBF_USS].[dbo].[SystemTable]')
		ELSE BEGIN
			UPDATE SS SET
				SYS_NAME = S.SystemFullName,
				SYS_SHORT_NAME = S.SystemShortName,
				SYS_ID_HOST = DH.HST_ID,
				SYS_ORDER = S.SystemOrder
			FROM [DBF_USS].[dbo.SystemTable] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.SYS_REG_NAME = S.SystemBaseName
			INNER JOIN dbo.Hosts AS H ON S.HostID = H.HostID
			INNER JOIN [DBF_USS].[dbo.HostTable] AS DH ON DH.HST_REG_FULL = H.HostReg
			WHERE S.SystemId = @System_Id;

			PRINT ('Обновлено в [DBF_USS].[dbo].[SystemTable]');
		END;

        INSERT INTO [BuhDB].[dbo].[SystemTable](SystemName, SystemPrefix, SystemGroupID, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, IsExpired)
        SELECT S.SystemFullName, '', 1, '', 0, 1, 1, 1, '', SystemBaseName, 0, 0
        FROM dbo.SystemTable AS S
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [BuhDB].[dbo].[SystemTable] AS Z
                    WHERE Z.SystemReg = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [BuhDB].[dbo].[SystemTable]')
		ELSE BEGIN
			UPDATE SS SET
				SystemName = S.SystemFullName
			FROM [BuhDB].[dbo].[SystemTable] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.SystemReg = S.SystemBaseName
			WHERE S.SystemID = @System_Id;

			PRINT ('Обновлено в [BuhDB].[dbo].[SystemTable]');
		END;

        INSERT INTO [BuhNahDB].[dbo].[SystemTable](SystemName, SystemPrefix, SystemGroupID, SystemPeriodicity, SystemServicePrice, SystemOrder, SaleObjectID, SystemPrint, SystemPostfix, SystemReg, SystemMain, IsExpired)
        SELECT S.SystemFullName, '', 1, '', 0, 1, 1, 1, '', SystemBaseName, 0, 0
        FROM dbo.SystemTable AS S
        WHERE S.SystemID = @System_Id
            AND NOT EXISTS
                (
                    SELECT *
                    FROM [BuhNahDB].[dbo].[SystemTable] AS Z
                    WHERE Z.SystemReg = S.SystemBaseName
                );

        IF @@RowCount > 0
            PRINT ('Добавлено в [BuhNahDB].[dbo].[SystemTable]')
		ELSE BEGIN
			UPDATE SS SET
				SystemName = S.SystemFullName
			FROM [BuhNahDB].[dbo].[SystemTable] AS SS
			INNER JOIN dbo.SystemTable AS S ON SS.SystemReg = S.SystemBaseName
			WHERE S.SystemID = @System_Id;

			PRINT ('Обновлено в [BuhNahDB].[dbo].[SystemTable]');
		END;

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
