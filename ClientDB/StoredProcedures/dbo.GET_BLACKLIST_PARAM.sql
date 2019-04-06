USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GET_BLACKLIST_PARAM]
@PARAMNAME varchar(50),
@paramValue varchar(2048) OUTPUT
WITH EXECUTE AS OWNER
AS
BEGIN
	SET @paramValue = ''
	SET NOCOUNT ON
	SET @paramValue=(SELECT PARAMVALUE
	FROM dbo.BLACK_LIST_PARAMS
	WHERE PARAMNAME=@PARAMNAME)
	SET NOCOUNT OFF
END