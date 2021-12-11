USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[USR].[COMPLECTS_DEACTIVATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [USR].[COMPLECTS_DEACTIVATE]  AS SELECT 1')
GO
ALTER PROCEDURE [USR].[COMPLECTS_DEACTIVATE]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@DebugError		VarChar(512),
		@DebugContext	Xml,
		@Params			Xml;

    DECLARE
        @UD_ID          Int,
        @Date           SmallDateTime;

    DECLARE @Complects TABLE (UD_ID Int PRIMARY KEY CLUSTERED);

	EXEC [Debug].[Execution@Start]
		@Proc_Id		= @@ProcId,
		@Params			= @Params,
		@DebugContext	= @DebugContext OUT

	BEGIN TRY

		SET @Date = DateAdd(Month, -3, GetDate());

        INSERT INTO @Complects
        SELECT D.UD_ID
        FROM USR.USRData D
		CROSS APPLY
		(
			SELECT TOP (1) UF_ID, UF_CREATE
			FROM USR.USRFile F
			WHERE F.UF_ID_COMPLECT = D.UD_ID
				AND F.UF_ACTIVE = 1
			ORDER BY F.UF_DATE DESC, F.UF_CREATE DESC
		) F
		OUTER APPLY
		(
			SELECT DS_REG
			FROM Reg.RegNodeSearchView R WITH(NOEXPAND)
			WHERE R.DistrNumber = D.UD_DISTR
				AND R.CompNumber = D.UD_COMP
				AND R.HostId = D.UD_ID_HOST
		) RN
		WHERE D.UD_ACTIVE = 1
			AND F.UF_CREATE < @Date
			AND NOT EXISTS
				(
					SELECT *
					FROM USR.USRPackage P
					INNER JOIN Reg.RegNodeSearchView R WITH(NOEXPAND) ON R.SystemID = P.UP_ID_SYSTEM AND R.DistrNumber = P.UP_DISTR AND R.CompNumber = P.UP_COMP
					WHERE P.UP_ID_USR = F.UF_ID
						AND R.DS_REG = 0
				);

		UPDATE D
		SET UD_ACTIVE = 0
		FROM USR.USRData        AS D
		INNER JOIN @Complects   AS C ON D.UD_ID = C.UD_ID;

        SET @UD_ID = 0;

        WHILE (1 = 1) BEGIN
            SELECT TOP (1)
                @UD_ID = UD_ID
            FROM @Complects
            WHERE UD_ID > @UD_ID
            ORDER BY
                UD_ID;

            IF @@RowCount < 1
                BREAK;

            EXEC [USR].[USR_ACTIVE_CACHE_REBUILD] @UD_ID = @UD_ID;
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
