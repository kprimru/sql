USE [FirstInstall]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [Meta].[REFERENCE_SELECT]
AS
BEGIN
	SET NOCOUNT ON;

	SELECT REF_ID, REF_NAME, REF_TITLE, REF_SCHEMA, REF_TABLE, REF_KEY, REF_VAL, REF_ID_MASTER, REF_MASTER_KEY, REF_LOG, REF_REF, REF_INSERT_SQL, REF_UPDATE_SQL, REF_CHRONO_SQL, REF_DELETE_SQL, REF_SELECT_SQL, REF_DELETED_SQL, REF_DEFAULT_SORT
	FROM Meta.Reference
END
GO
GRANT EXECUTE ON [Meta].[REFERENCE_SELECT] TO public;
GO