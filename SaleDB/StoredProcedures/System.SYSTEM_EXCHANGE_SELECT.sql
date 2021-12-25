USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [System].[SYSTEM_EXCHANGE_SELECT]
	@FILTER	VARCHAR(100) = NULL
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

	SELECT ID, SHORT, HOST
	FROM System.Systems a
	WHERE EXISTS
		(
			SELECT *
			FROM System.Systems b
			WHERE a.HOST = b.HOST
				AND a.ID <> b.ID
		)
	ORDER BY ORD
END

GO
GRANT EXECUTE ON [System].[SYSTEM_EXCHANGE_SELECT] TO rl_system_r;
GO
