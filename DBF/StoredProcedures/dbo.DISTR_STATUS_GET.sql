USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/*
�����:		  ������� �������
��������:	  
*/

CREATE PROCEDURE [dbo].[DISTR_STATUS_GET]  
	@dsid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DS_NAME, DS_REG, DS_ACTIVE
	FROM dbo.DistrStatusTable
	WHERE DS_ID = @dsid

	SET	NOCOUNT OFF
END












