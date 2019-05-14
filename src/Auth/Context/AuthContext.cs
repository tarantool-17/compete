using Auth.Context.Entities;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Auth.Context
{
    public class AuthContext : IdentityDbContext<ApplicationUser, ApplicationRole, int>
    {
        public AuthContext(DbContextOptions<AuthContext> options)
            : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder builder)
        {
            base.OnModelCreating(builder);
            
            builder.HasDefaultSchema("auth");
            
            builder.Entity<ApplicationUser>().ToTable("users");
            builder.Entity<ApplicationRole>().ToTable("roles");
            builder.Entity<IdentityUserClaim<int>>().ToTable("user_claim");
            builder.Entity<IdentityUserRole<int>>().ToTable("user_role");
            builder.Entity<IdentityUserLogin<int>>().ToTable("user_login");
            builder.Entity<IdentityRoleClaim<int>>().ToTable("role_claim");
            builder.Entity<IdentityUserToken<int>>().ToTable("user_token");

            ToSnakeCase(builder);
        }
        
        private void ToSnakeCase(ModelBuilder builder)
        {
            foreach(var entity in builder.Model.GetEntityTypes())
            {
                // Replace table names
                entity.Relational().TableName = entity.Relational().TableName.ToSnakeCase();

                // Replace column names            
                foreach(var property in entity.GetProperties())
                {
                    property.Relational().ColumnName = property.Relational().ColumnName.ToSnakeCase();
                }

                foreach(var key in entity.GetKeys())
                {
                    key.Relational().Name = key.Relational().Name.ToSnakeCase();
                }

                foreach(var key in entity.GetForeignKeys())
                {
                    key.Relational().Name = key.Relational().Name.ToSnakeCase();
                }

                foreach(var index in entity.GetIndexes())
                {
                    index.Relational().Name = index.Relational().Name.ToSnakeCase();
                }
            }
        }
    }
}