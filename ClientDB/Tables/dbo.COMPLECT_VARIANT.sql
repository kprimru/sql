USE [ClientDB]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COMPLECT_VARIANT]
(
        [ID]     Int           Identity(1,1)   NOT NULL,
        [NAME]   VarChar(50)                   NOT NULL,
        CONSTRAINT [PK_dbo.COMPLECT_VARIANT] PRIMARY KEY CLUSTERED ([ID])
);GO
GRANT ALTER ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT CONTROL ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT DELETE ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT INSERT ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT REFERENCES ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT SELECT ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GRANT UPDATE ON [dbo].[COMPLECT_VARIANT] TO COMPLECTBASE;
GO
