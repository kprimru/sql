USE [DBF_NAH]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
�����:		  ������� �������
��������:	  ������� ������ � �����������, ���� ������ ���� ������������
*/

ALTER PROCEDURE [dbo].[REFERENCE_GET]
	@refname VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		REF_ID, REF_SCHEMA, REF_NAME, REF_TITLE, REF_FIELD_ID, REF_FIELD_NAME,
		REF_READ_ONLY
	FROM dbo.ReferenceTable
	WHERE REF_NAME = @refname 

	SET NOCOUNT OFF
END






GO
GRANT EXECUTE ON [dbo].[REFERENCE_GET] TO rl_all_r;
GO