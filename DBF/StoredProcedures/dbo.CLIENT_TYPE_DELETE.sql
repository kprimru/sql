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

CREATE PROCEDURE [dbo].[CLIENT_TYPE_DELETE] 
	@id SMALLINT
AS
BEGIN
	SET NOCOUNT ON

	DELETE 
	FROM dbo.ClientTypeTable 
	WHERE CLT_ID = @id

	SET NOCOUNT OFF
END
