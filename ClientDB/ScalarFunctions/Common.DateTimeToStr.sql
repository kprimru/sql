﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Common].[DateTimeToStr]', 'FN') IS NULL EXEC('CREATE FUNCTION [Common].[DateTimeToStr] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [Common].[DateTimeToStr]
(
	@Value	DateTime
)
RETURNS VarChar(100)
WITH SCHEMABINDING
AS
BEGIN
	RETURN
		Convert(VarChar(20), @Value, 104) + ' ' + Convert(VarChar(20), @Value, 108);
END
GO
