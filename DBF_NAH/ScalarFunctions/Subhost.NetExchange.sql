﻿USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Subhost].[NetExchange]', 'FN') IS NULL EXEC('CREATE FUNCTION [Subhost].[NetExchange] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Subhost].[NetExchange]
(
	@SN_OLD	SMALLINT,
	@SN_NEW	SMALLINT,
	@TT_OLD	SMALLINT,
	@TT_NEW	SMALLINT
)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @RES VARCHAR(100)

	SELECT @RES =
		CASE
			WHEN
				TT_OLD IS NULL AND TT_NEW IS NULL
				AND SN_OLD IS NOT NULL AND SN_NEW IS NOT NULL
				THEN 'с ' + SOLD.SN_NAME + ' на ' + SNEW.SN_NAME
			WHEN
				TT_OLD IS NOT NULL AND TT_NEW IS NOT NULL
				AND SN_OLD IS NULL AND SN_NEW IS NULL
				THEN
				CASE
					WHEN TT_OLD > TT_NEW
						THEN 'с ' + TOLD.TT_NAME + ' на ' + 'лок'
						ELSE 'с ' + 'лок' + ' на ' + TNEW.TT_NAME
					END
			WHEN TT_OLD IS NOT NULL AND TT_NEW IS NOT NULL AND SN_OLD IS NOT NULL AND SN_NEW IS NOT NULL
				THEN
					CASE
						WHEN TT_OLD > TT_NEW
							THEN 'с ' + TOLD.TT_NAME + ' на ' + SNEW.SN_NAME
						ELSE 'с ' + SOLD.SN_NAME + ' на ' + TNEW.TT_NAME
					END
			ELSE NULL
		END
	FROM
		(
			SELECT @SN_OLD AS SN_OLD, @SN_NEW AS SN_NEW, @TT_OLD AS TT_OLD, @TT_NEW AS TT_NEW
		) AS o_O
		LEFT OUTER JOIN dbo.TechnolTypeTable TOLD ON TOLD.TT_ID = TT_OLD
		LEFT OUTER JOIN dbo.TechnolTypeTable TNEW ON TNEW.TT_ID = TT_NEW
		LEFT OUTER JOIN dbo.SystemNetTable SOLD ON SOLD.SN_ID = SN_OLD
		LEFT OUTER JOIN dbo.SystemNetTable SNEW ON SNEW.SN_ID = SN_NEW

	RETURN @RES
END

GO
