USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Security].[PASSWORD_GENERATE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [Security].[PASSWORD_GENERATE]  AS SELECT 1')
GO
ALTER PROCEDURE [Security].[PASSWORD_GENERATE]
	@MODE	TINYINT = 1
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE
        @DebugError     VarChar(512),
        @DebugContext   Xml,
        @Params         Xml;

    EXEC [Debug].[Execution@Start]
        @Proc_Id        = @@ProcId,
        @Params         = @Params,
        @DebugContext   = @DebugContext OUT

	BEGIN TRY
		IF @MODE = 3
			SELECT
				ONE, TWO, THREE,
				LEFT(ONE, 3) + LEFT(TWO, 3) + LEFT(THREE, 3) AS SHORT
			FROM
				(
					SELECT
						(
							SELECT TOP 1 NAME
							FROM Common.Words
							WHERE TYPE = 1
							ORDER BY NEWID()
						) AS ONE,
						(
							SELECT TOP 1 NAME
							FROM Common.Words
							WHERE TYPE = 2
							ORDER BY NEWID()
						) AS TWO,
						(
							SELECT TOP 1 NAME
							FROM Common.Words
							WHERE TYPE = 3
							ORDER BY NEWID()
						) AS THREE
				) AS o_O
		ELSE IF @MODE = 2
			SELECT
				ONE, TWO,
				LEFT(ONE, 3) + LEFT(TWO, 3) AS SHORT
			FROM
				(
					SELECT
					(
						SELECT TOP 1 NAME
						FROM Common.Words
						WHERE TYPE = 4
						ORDER BY NEWID()
					) AS ONE,
					(
						SELECT TOP 1 NAME
						FROM Common.Words
						WHERE TYPE = 1
						ORDER BY NEWID()
					) AS TWO
			) AS o_O
		ELSE IF @MODE = 1
			SELECT
				ONE AS SHORT
			FROM
				(
					SELECT
						(
							SELECT TOP 1 NAME
							FROM Common.Words
							WHERE TYPE = 1
							ORDER BY NEWID()
						) AS ONE
				) AS o_O

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
