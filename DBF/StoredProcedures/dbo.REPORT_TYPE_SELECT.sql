USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Автор:		  коллектив авторов
Описание:
*/

CREATE PROCEDURE [dbo].[REPORT_TYPE_SELECT] 
  @active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RTY_ID, RTY_NAME
	FROM dbo.ReportTypeTable
--	WHERE RT_ACTIVE=@active

	SET NOCOUNT OFF
END




