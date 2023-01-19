USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF OBJECT_ID('[dbo].[PrepareFileName]', 'FN') IS NULL EXEC('CREATE FUNCTION [dbo].[PrepareFileName] () RETURNS Int AS BEGIN RETURN NULL END')
GO
CREATE FUNCTION [dbo].[PrepareFileName]
(
	@FileName	VarChar(4000)
)
RETURNS VarChar(4000)
AS
BEGIN
	RETURN Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(Replace(@FileName, '\', '_'), '/', '_'), '>', '_'), '?', '_'), ':', '_'), '*', '_'), '<', '_'), '"', '_'), '|', '_');
END
GO
