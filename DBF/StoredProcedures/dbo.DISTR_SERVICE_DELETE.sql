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

CREATE PROCEDURE [dbo].[DISTR_SERVICE_DELETE] 
	@dsid SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.SystemServiceTable 
	WHERE DSS_ID = @dsid

	SET NOCOUNT OFF
END


