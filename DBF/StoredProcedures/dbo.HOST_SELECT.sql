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

CREATE PROCEDURE [dbo].[HOST_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT HST_ID, HST_NAME, HST_REG_NAME 
	FROM dbo.HostTable 
	WHERE HST_ACTIVE = ISNULL(@active, HST_ACTIVE)
	ORDER BY HST_NAME

	SET NOCOUNT OFF
END







