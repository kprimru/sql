﻿USE [DocumentClaim]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[Debug].[Execution@Enabled]', 'FN') IS NULL EXEC('CREATE FUNCTION [Debug].[Execution@Enabled] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE   FUNCTION [Debug].[Execution@Enabled]()
RETURNS Bit
AS
BEGIN
	RETURN 0;
END
GO
