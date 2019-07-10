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

CREATE PROCEDURE [dbo].[DISTR_STATUS_SELECT]  
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DS_ID, DS_NAME, DS_REG
	FROM dbo.DistrStatusTable
	WHERE DS_ACTIVE = ISNULL(@active, DS_ACTIVE)
	ORDER BY DS_NAME

	SET NOCOUNT OFF
END












