USE [ScanDoc]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CategoryUsers]
(
        [ID]            Int   Identity(1,1)   NOT NULL,
        [ID_CATEGORY]   Int                   NOT NULL,
        [ID_USER]       Int                   NOT NULL,
        [R]             Bit                   NOT NULL,
        [W]             Bit                   NOT NULL,
        CONSTRAINT [PK_CategoryUsers] PRIMARY KEY CLUSTERED ([ID]),
        CONSTRAINT [FK_CategoryUsers_Users] FOREIGN KEY  ([ID_USER]) REFERENCES [dbo].[Users] ([ID]),
        CONSTRAINT [FK_CategoryUsers_Category] FOREIGN KEY  ([ID_CATEGORY]) REFERENCES [dbo].[Category] ([ID])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_U_CATEGORY_USER] ON [dbo].[CategoryUsers] ([ID_CATEGORY] ASC, [ID_USER] ASC);
GO
