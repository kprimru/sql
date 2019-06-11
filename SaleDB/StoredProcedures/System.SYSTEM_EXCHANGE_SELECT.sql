USE [SaleDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [System].[SYSTEM_EXCHANGE_SELECT]
	@FILTER	VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

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
