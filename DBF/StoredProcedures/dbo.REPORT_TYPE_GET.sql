USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ��������� �������
��������:
*/

CREATE PROCEDURE [dbo].[REPORT_TYPE_GET] 
  @rtid int = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT RTY_ID, RTY_NAME
	FROM dbo.ReportTypeTable
	WHERE RTY_ID = @rtid

	SET NOCOUNT OFF
END

