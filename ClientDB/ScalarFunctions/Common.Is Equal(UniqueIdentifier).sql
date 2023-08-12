﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[Is Equal(UniqueIdentifier)]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[Is Equal(UniqueIdentifier)] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE OR ALTER FUNCTION [Common].[Is Equal(UniqueIdentifier)]
(
	@V1	UniqueIdentifier,
	@V2	UniqueIdentifier
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
