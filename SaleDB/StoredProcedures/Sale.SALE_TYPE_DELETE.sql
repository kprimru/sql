USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Sale].[SALE_TYPE_DELETE]
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
				FROM Sale.SaleType
			) AS o_O
		WHERE ID = @ID

		SELECT TOP 1 @NEW_ID = ID
		FROM
			(
				SELECT ID, ROW_NUMBER() OVER(ORDER BY NAME) AS RN
				FROM Sale.SaleType
			) AS o_O
		WHERE ID <> @ID
			AND RN IN
				(
					SELECT @RN + 1
					UNION ALL
					SELECT @RN - 1
				)

		DELETE
		FROM	Sale.SaleType
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
GRANT EXECUTE ON [Sale].[SALE_TYPE_DELETE] TO rl_sale_type_d;
GO
