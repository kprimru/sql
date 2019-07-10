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

CREATE PROCEDURE [dbo].[DISTR_EXCEPT_GET]  
	@distrid INT = NULL  
AS
BEGIN
	SET NOCOUNT ON

	SELECT DE_DIS_NUM, DE_COMP_NUM, SYS_ID, SYS_SHORT_NAME, DE_ACTIVE, DE_COMMENT
	FROM 
		dbo.DistrExceptTable INNER JOIN
		dbo.SystemTable ON SYS_ID = DE_ID_SYSTEM
	WHERE DE_ID = @distrid

	SET NOCOUNT OFF
END
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_GET] TO rl_reg_node_report_r