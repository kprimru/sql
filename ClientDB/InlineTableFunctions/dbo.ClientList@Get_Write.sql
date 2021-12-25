﻿USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[ClientList@Get?Write]', 'IF') IS NULL EXEC('CREATE FUNCTION [dbo].[ClientList@Get?Write] () RETURNS TABLE AS RETURN (SELECT [NULL] = NULL)')
GO
ALTER FUNCTION [dbo].[ClientList@Get?Write]()
RETURNS TABLE
AS
RETURN
(
	SELECT WCL_ID = ClientID
	FROM [dbo].[ClientList@Get]('WRITE')
)
GO
