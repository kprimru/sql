USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[System].[CATEGORY_DELETE]', 'P ') IS NULL EXEC('CREATE PROCEDURE [System].[CATEGORY_DELETE]  AS SELECT 1')
GO
ALTER PROCEDURE [System].[CATEGORY_DELETE]
	@ID		UNIQUEIDENTIFIER,
	@NEW_ID	UNIQUEIDENTIFIER = NULL OUTPUT
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
		DECLARE @RN	BIGINT

		SELECT @RN = RN
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM System.Category
			) AS o_O
		WHERE ID = @ID

		SELECT TOP 1 @NEW_ID = ID
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM System.Category
			) AS o_O
		WHERE ID <> @ID
			AND RN IN
				(
					SELECT @RN + 1
					UNION ALL
					SELECT @RN - 1
				)

		DELETE
		FROM	System.Category
		WHERE	ID		=	@ID

		EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = NULL;
    END TRY
    BEGIN CATCH
        SET @DebugError = Error_Message();

        EXEC [Debug].[Execution@Finish] @DebugContext = @DebugContext, @Error = @DebugError;

        EXEC [Maintenance].[ReRaise Error];
    END CATCH
END
GO
GRANT EXECUTE ON [System].[CATEGORY_DELETE] TO rl_sys_category_d;
GO
