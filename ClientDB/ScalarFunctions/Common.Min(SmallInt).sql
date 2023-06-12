﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[Min(SmallInt)]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[Min(SmallInt)] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[Min(SmallInt)]
(
	@V1	SmallInt,
	@V2	SmallInt
)
RETURNS Bit
WITH SCHEMABINDING, RETURNS NULL ON NULL INPUT
AS
BEGIN
	RETURN CASE WHEN @V1 < @V2 THEN @V1 ELSE @V2 END
END
GO
