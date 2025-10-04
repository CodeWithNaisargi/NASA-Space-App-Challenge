"""
Machine Learning Model Training for Air Quality Prediction
NASA Space Apps Challenge - Air Quality Prediction Project
"""

import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import cross_val_score, GridSearchCV
import joblib
import matplotlib.pyplot as plt
import seaborn as sns
import warnings

warnings.filterwarnings("ignore")


class AirQualityModelTrainer:
    def __init__(self, processed_data):
        """Initialize trainer with processed data"""
        self.X_train = processed_data["X_train"]
        self.X_test = processed_data["X_test"]
        self.y_train = processed_data["y_train"]
        self.y_test = processed_data["y_test"]
        self.scaler = processed_data["scaler"]
        self.feature_names = processed_data["feature_names"]
        self.aqi_labels = processed_data["aqi_labels"]

        self.models = {}
        self.results = {}

    def initialize_models(self):
        """Initialize all models to be trained"""
        self.models = {
            "Logistic Regression": LogisticRegression(random_state=42, max_iter=1000),
            "Random Forest": RandomForestClassifier(random_state=42, n_estimators=100),
            "Decision Tree": DecisionTreeClassifier(random_state=42),
            "SVM": SVC(random_state=42, probability=True),
            "Gradient Boosting": GradientBoostingClassifier(random_state=42),
        }
        print("Models initialized successfully!")

    def train_models(self):
        """Train all models and evaluate them"""
        print("Training models...")

        for name, model in self.models.items():
            print(f"\nTraining {name}...")

            # Train the model
            model.fit(self.X_train, self.y_train)

            # Make predictions
            y_pred = model.predict(self.X_test)
            y_pred_proba = (
                model.predict_proba(self.X_test)
                if hasattr(model, "predict_proba")
                else None
            )

            # Calculate metrics
            accuracy = accuracy_score(self.y_test, y_pred)
            mae = mean_absolute_error(self.y_test, y_pred)
            mse = mean_squared_error(self.y_test, y_pred)
            r2 = r2_score(self.y_test, y_pred)

            # Cross-validation score
            cv_scores = cross_val_score(model, self.X_train, self.y_train, cv=5)
            cv_mean = cv_scores.mean()
            cv_std = cv_scores.std()

            # Store results
            self.results[name] = {
                "model": model,
                "accuracy": accuracy,
                "mae": mae,
                "mse": mse,
                "r2": r2,
                "cv_mean": cv_mean,
                "cv_std": cv_std,
                "predictions": y_pred,
                "probabilities": y_pred_proba,
            }

            print(
                f"{name} - Accuracy: {accuracy:.4f}, CV Score: {cv_mean:.4f} (+/- {cv_std*2:.4f})"
            )

    def hyperparameter_tuning(self):
        """Perform hyperparameter tuning for the best models"""
        print("\nPerforming hyperparameter tuning...")

        # Random Forest tuning
        rf_params = {
            "n_estimators": [50, 100, 200],
            "max_depth": [10, 20, None],
            "min_samples_split": [2, 5, 10],
        }

        rf_grid = GridSearchCV(
            RandomForestClassifier(random_state=42),
            rf_params,
            cv=3,
            scoring="accuracy",
            n_jobs=-1,
        )
        rf_grid.fit(self.X_train, self.y_train)

        # Update the best Random Forest model
        self.models["Random Forest"] = rf_grid.best_estimator_
        self.results["Random Forest"]["model"] = rf_grid.best_estimator_

        print(f"Best Random Forest parameters: {rf_grid.best_params_}")
        print(f"Best Random Forest CV score: {rf_grid.best_score_:.4f}")

        # Gradient Boosting tuning
        gb_params = {
            "n_estimators": [50, 100, 200],
            "learning_rate": [0.01, 0.1, 0.2],
            "max_depth": [3, 5, 7],
        }

        gb_grid = GridSearchCV(
            GradientBoostingClassifier(random_state=42),
            gb_params,
            cv=3,
            scoring="accuracy",
            n_jobs=-1,
        )
        gb_grid.fit(self.X_train, self.y_train)

        # Update the best Gradient Boosting model
        self.models["Gradient Boosting"] = gb_grid.best_estimator_
        self.results["Gradient Boosting"]["model"] = gb_grid.best_estimator_

        print(f"Best Gradient Boosting parameters: {gb_grid.best_params_}")
        print(f"Best Gradient Boosting CV score: {gb_grid.best_score_:.4f}")

    def evaluate_models(self):
        """Evaluate and compare all models"""
        print("\n" + "=" * 60)
        print("MODEL EVALUATION RESULTS")
        print("=" * 60)

        # Create results DataFrame
        results_df = pd.DataFrame(
            {
                "Model": list(self.results.keys()),
                "Accuracy": [
                    self.results[name]["accuracy"] for name in self.results.keys()
                ],
                "MAE": [self.results[name]["mae"] for name in self.results.keys()],
                "MSE": [self.results[name]["mse"] for name in self.results.keys()],
                "R²": [self.results[name]["r2"] for name in self.results.keys()],
                "CV Score": [
                    self.results[name]["cv_mean"] for name in self.results.keys()
                ],
                "CV Std": [
                    self.results[name]["cv_std"] for name in self.results.keys()
                ],
            }
        )

        # Sort by accuracy
        results_df = results_df.sort_values("Accuracy", ascending=False)
        print(results_df.to_string(index=False, float_format="%.4f"))

        # Find best model
        best_model_name = results_df.iloc[0]["Model"]
        best_model = self.results[best_model_name]["model"]

        print(f"\nBest Model: {best_model_name}")
        print(f"Best Accuracy: {results_df.iloc[0]['Accuracy']:.4f}")

        return best_model_name, best_model

    def create_visualizations(self):
        """Create visualizations for model evaluation"""
        print("\nCreating evaluation visualizations...")

        # Set up the plotting style
        plt.style.use("dark_background")
        fig, axes = plt.subplots(2, 2, figsize=(15, 12))
        fig.suptitle("Model Evaluation Results", fontsize=16, color="white")

        # Model comparison
        model_names = list(self.results.keys())
        accuracies = [self.results[name]["accuracy"] for name in model_names]

        bars = axes[0, 0].bar(
            model_names,
            accuracies,
            color=["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7"],
        )
        axes[0, 0].set_title("Model Accuracy Comparison", color="white")
        axes[0, 0].set_ylabel("Accuracy", color="white")
        axes[0, 0].tick_params(axis="x", rotation=45, colors="white")
        axes[0, 0].tick_params(axis="y", colors="white")

        # Add value labels on bars
        for bar, acc in zip(bars, accuracies):
            axes[0, 0].text(
                bar.get_x() + bar.get_width() / 2,
                bar.get_height() + 0.01,
                f"{acc:.3f}",
                ha="center",
                va="bottom",
                color="white",
            )

        # Cross-validation scores
        cv_means = [self.results[name]["cv_mean"] for name in model_names]
        cv_stds = [self.results[name]["cv_std"] for name in model_names]

        axes[0, 1].bar(
            model_names,
            cv_means,
            yerr=cv_stds,
            capsize=5,
            color=["#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FFEAA7"],
        )
        axes[0, 1].set_title("Cross-Validation Scores", color="white")
        axes[0, 1].set_ylabel("CV Score", color="white")
        axes[0, 1].tick_params(axis="x", rotation=45, colors="white")
        axes[0, 1].tick_params(axis="y", colors="white")

        # Confusion Matrix for best model
        best_model_name = max(
            self.results.keys(), key=lambda x: self.results[x]["accuracy"]
        )
        y_pred = self.results[best_model_name]["predictions"]

        cm = confusion_matrix(self.y_test, y_pred)
        sns.heatmap(
            cm,
            annot=True,
            fmt="d",
            cmap="Blues",
            ax=axes[1, 0],
            xticklabels=list(self.aqi_labels.values()),
            yticklabels=list(self.aqi_labels.values()),
        )
        axes[1, 0].set_title(f"Confusion Matrix - {best_model_name}", color="white")
        axes[1, 0].set_xlabel("Predicted", color="white")
        axes[1, 0].set_ylabel("Actual", color="white")

        # Feature importance (for tree-based models)
        if hasattr(self.results[best_model_name]["model"], "feature_importances_"):
            importances = self.results[best_model_name]["model"].feature_importances_
            indices = np.argsort(importances)[::-1][:10]  # Top 10 features

            axes[1, 1].bar(range(10), importances[indices], color="lightcoral")
            axes[1, 1].set_title(
                f"Top 10 Feature Importances - {best_model_name}", color="white"
            )
            axes[1, 1].set_xlabel("Features", color="white")
            axes[1, 1].set_ylabel("Importance", color="white")
            axes[1, 1].set_xticks(range(10))
            axes[1, 1].set_xticklabels(
                [self.feature_names[i] for i in indices],
                rotation=45,
                ha="right",
                color="white",
            )
            axes[1, 1].tick_params(axis="y", colors="white")

        plt.tight_layout()
        plt.savefig(
            "model_evaluation.png",
            dpi=300,
            bbox_inches="tight",
            facecolor="black",
            edgecolor="none",
        )
        plt.show()

        print("Visualizations saved as 'model_evaluation.png'")

    def save_best_model(self, model_name, model):
        """Save the best model and scaler"""
        print(f"\nSaving best model: {model_name}")

        # Save the model
        joblib.dump(model, "best_air_quality_model.pkl")

        # Save the scaler
        joblib.dump(self.scaler, "air_quality_scaler.pkl")

        # Save model metadata
        metadata = {
            "model_name": model_name,
            "feature_names": self.feature_names,
            "aqi_labels": self.aqi_labels,
            "accuracy": self.results[model_name]["accuracy"],
            "model_type": type(model).__name__,
        }

        joblib.dump(metadata, "model_metadata.pkl")

        print("Model, scaler, and metadata saved successfully!")
        print("Files created:")
        print("- best_air_quality_model.pkl")
        print("- air_quality_scaler.pkl")
        print("- model_metadata.pkl")

    def generate_classification_report(self, model_name):
        """Generate detailed classification report"""
        print(f"\nDetailed Classification Report for {model_name}:")
        print("=" * 60)

        y_pred = self.results[model_name]["predictions"]
        report = classification_report(
            self.y_test, y_pred, target_names=list(self.aqi_labels.values())
        )
        print(report)

    def train_and_evaluate(self):
        """Complete training and evaluation pipeline"""
        print("Starting Air Quality Model Training Pipeline")
        print("=" * 50)

        # Initialize and train models
        self.initialize_models()
        self.train_models()

        # Hyperparameter tuning
        self.hyperparameter_tuning()

        # Re-train with best parameters
        self.train_models()

        # Evaluate models
        best_model_name, best_model = self.evaluate_models()

        # Generate detailed report
        self.generate_classification_report(best_model_name)

        # Create visualizations
        self.create_visualizations()

        # Save best model
        self.save_best_model(best_model_name, best_model)

        return best_model_name, best_model, self.results


def main():
    """Main function to run the training pipeline"""
    # Import processed data
    from data_processing import main as process_data

    processed_data = process_data()

    # Initialize trainer
    trainer = AirQualityModelTrainer(processed_data)

    # Train and evaluate
    best_model_name, best_model, results = trainer.train_and_evaluate()

    print(f"\nTraining completed! Best model: {best_model_name}")
    return trainer


if __name__ == "__main__":
    trainer = main()
