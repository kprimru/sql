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

CREATE PROCEDURE [dbo].[DISTR_EXCEPT_SELECT]    
	@active BIT = NULL
AS
BEGIN
	SET NOCOUNT ON

	SELECT DE_ID, SYS_SHORT_NAME, DE_DIS_NUM, DE_COMP_NUM, DE_COMMENT
	FROM 
		dbo.DistrExceptTable INNER JOIN
		dbo.SystemTable ON SYS_ID = DE_ID_SYSTEM
	WHERE DE_ACTIVE = ISNULL(@active, DE_ACTIVE)
	ORDER BY SYS_ORDER, DE_DIS_NUM, DE_COMP_NUM

	SET NOCOUNT OFF
END
GRANT EXECUTE ON [dbo].[DISTR_EXCEPT_SELECT] TO rL_reg_node_report_r