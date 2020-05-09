USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [USR].[USR_ACTIVE_CACHE_REBUILD]
    @UD_ID      Int
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

        IF @UD_ID IS NULL BEGIN
            TRUNCATE TABLE Cache.USRActive;

            INSERT INTO Cache.USRActive(UD_ID, UF_ID, UD_DISTR, UD_COMP, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UD_ID_CLIENT, UF_CREATE, UF_PATH, UD_ACTIVE, UF_ID_SYSTEM, UD_ID_HOST)
            SELECT UD_ID, UF_ID, UD_DISTR, UD_COMP, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UD_ID_CLIENT, UF_CREATE, UF_PATH, UD_ACTIVE, UF_ID_SYSTEM, UD_ID_HOST
            FROM [USR].[USRActiveView?Cache] AS U;
        END
        ELSE BEGIN
            IF NOT EXISTS(SELECT * FROM [USR].[USRActiveView?Cache] AS U WHERE U.UD_ID = @UD_ID)
                DELETE FROM Cache.USRActive WHERE UD_ID = @UD_ID;
            ELSE BEGIN
                UPDATE C
                SET UF_ID                   = U.UF_ID,
                    UD_DISTR                = U.UD_DISTR,
                    UD_COMP                 = U.UD_COMP,
                    UF_DATE                 = U.UF_DATE,
                    USRFileKindShortName    = U.USRFileKindShortName,
                    UF_UPTIME               = U.UF_UPTIME,
                    UF_ACTIVE               = U.UF_ACTIVE,
                    UD_ID_CLIENT            = U.UD_ID_CLIENT,
                    UF_CREATE               = U.UF_CREATE,
                    UF_PATH                 = U.UF_PATH,
                    UD_ACTIVE               = U.UD_ACTIVE,
                    UF_ID_SYSTEM            = U.UF_ID_SYSTEM,
                    UD_ID_HOST              = U.UD_ID_HOST
                FROM Cache.USRActive AS C
                CROSS APPLY
                (
                    SELECT *
                    FROM [USR].[USRActiveView?Cache] AS U
                    WHERE U.UD_ID = @UD_ID
                ) AS U
                WHERE C.UD_ID = @UD_ID

                IF @@RowCount = 0
                    INSERT INTO Cache.USRActive(UD_ID, UF_ID, UD_DISTR, UD_COMP, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UD_ID_CLIENT, UF_CREATE, UF_PATH, UD_ACTIVE, UF_ID_SYSTEM, UD_ID_HOST)
                    SELECT UD_ID, UF_ID, UD_DISTR, UD_COMP, UF_DATE, USRFileKindShortName, UF_UPTIME, UF_ACTIVE, UD_ID_CLIENT, UF_CREATE, UF_PATH, UD_ACTIVE, UF_ID_SYSTEM, UD_ID_HOST
                    FROM [USR].[USRActiveView?Cache] AS U
                    WHERE U.UD_ID = @UD_ID
            END
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
