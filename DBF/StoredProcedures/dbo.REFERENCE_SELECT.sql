USE [DBF]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  ������� ������ � �����������, ���� ������ ���� ������������
*/

CREATE PROCEDURE [dbo].[REFERENCE_SELECT] 
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT 
			REF_ID, REF_NAME, REF_TITLE, REF_FIELD_ID, REF_FIELD_NAME, 
			REF_READ_ONLY 
	FROM dbo.ReferenceTable 
	ORDER BY REF_TITLE
	
	SET NOCOUNT OFF
END





