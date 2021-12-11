USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[Is Equal(SmallDateTime)]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[Is Equal(SmallDateTime)] () RETURNS Int AS BEGIN RETURN NULL END')
GO
ALTER FUNCTION [Common].[Is Equal(SmallDateTime)]
(
	@V1	SmallDateTime,
	@V2	SmallDateTime
)
RETURNS Bit
WITH SCHEMABINDING
AS
BEGIN
	RETURN
		CASE
			WHEN @V1 IS NULL AND @V2 IS NULL THEN 1
			WHEN @V1 IS NULL AND @V2 IS NOT NULL THEN 0
			WHEN @V1 IS NOT NULL AND @V2 IS NULL THEN 0
			WHEN @V1 = @V2 THEN 1
			ELSE 0
		END
END
GO
