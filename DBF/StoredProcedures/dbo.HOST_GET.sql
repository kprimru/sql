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

CREATE PROCEDURE [dbo].[HOST_GET] 
	@hostid SMALLINT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT HST_ID, HST_NAME, HST_REG_NAME, HST_ACTIVE
	FROM dbo.HostTable 
	WHERE HST_ID = @hostid

	SET NOCOUNT OFF
END








